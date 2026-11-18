import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/call_outcome.dart';
import '../models/point_ledger_entry.dart';
import '../models/recitation_session.dart';
import '../models/student.dart';
import '../models/student_session_state.dart';

class RecitroStore extends ChangeNotifier {
  RecitroStore();

  static const _uuid = Uuid();
  static const int primaryPickWeight = 10;
  static const int answeredRecallPickWeight = 2;
  final List<Student> _students = [];
  final List<RecitationSession> _sessions = [];
  final List<PointLedgerEntry> _ledger = [];

  List<Student> get students => List.unmodifiable(_students);
  List<RecitationSession> get sessions => List.unmodifiable(_sessions);
  List<PointLedgerEntry> get ledger => List.unmodifiable(_ledger);

  Future<void> init() async {
    await _load();
  }

  Student? studentById(String id) {
    for (final s in _students) {
      if (s.id == id) return s;
    }
    return null;
  }

  RecitationSession? sessionById(String id) {
    for (final s in _sessions) {
      if (s.id == id) return s;
    }
    return null;
  }

  int totalPointsForStudent(String studentId) {
    var sum = 0;
    for (final e in _ledger) {
      if (e.studentId == studentId) sum += e.points;
    }
    return sum;
  }

  List<PointLedgerEntry> ledgerForStudent(String studentId) {
    final list =
        _ledger.where((e) => e.studentId == studentId).toList(growable: false);
    list.sort((a, b) => b.earnedAt.compareTo(a.earnedAt));
    return list;
  }

  Future<void> addStudent(String name) async {
    final student = Student(id: _uuid.v4(), name: name.trim());
    _students.add(student);
    for (final session in _sessions) {
      session.studentStates[student.id] = StudentSessionState(
        studentId: student.id,
      );
    }
    await _save();
    notifyListeners();
  }

  Future<void> updateStudent(String id, String name) async {
    final student = studentById(id);
    if (student == null) return;
    student.name = name.trim();
    await _save();
    notifyListeners();
  }

  Future<void> deleteStudent(String id) async {
    _students.removeWhere((s) => s.id == id);
    for (final session in _sessions) {
      session.studentStates.remove(id);
      if (session.pendingStudentId == id) {
        session.pendingStudentId = null;
      }
    }
    await _save();
    notifyListeners();
  }

  Future<void> addSession({
    required String name,
    required int pointsPerAnswer,
    required String rewardLabel,
    required bool allowRecallUnanswered,
    required bool allowRecallAnswered,
  }) async {
    final states = <String, StudentSessionState>{};
    for (final student in _students) {
      states[student.id] = StudentSessionState(studentId: student.id);
    }
    _sessions.add(
      RecitationSession(
        id: _uuid.v4(),
        name: name.trim(),
        pointsPerAnswer: pointsPerAnswer,
        rewardLabel: rewardLabel.trim(),
        allowRecallUnanswered: allowRecallUnanswered,
        allowRecallAnswered: allowRecallAnswered,
        studentStates: states,
      ),
    );
    await _save();
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    await _save();
    notifyListeners();
  }

  int pickWeightForStudent(RecitationSession session, Student student) {
    if (session.pendingStudentId != null) return 0;
    final state = session.studentStates[student.id];
    if (state == null || state.outcome == CallOutcome.pending) return 0;
    return switch (state.outcome) {
      CallOutcome.notCalled => primaryPickWeight,
      CallOutcome.notAnswered =>
        session.allowRecallUnanswered ? primaryPickWeight : 0,
      CallOutcome.answered =>
        session.allowRecallAnswered ? answeredRecallPickWeight : 0,
      CallOutcome.pending => 0,
    };
  }

  bool hasCallableStudents(RecitationSession session) {
    if (session.pendingStudentId != null) return false;
    for (final student in _students) {
      if (pickWeightForStudent(session, student) > 0) return true;
    }
    return false;
  }

  List<Student> eligibleStudents(RecitationSession session) {
    return _students
        .where((s) => pickWeightForStudent(session, s) > 0)
        .toList(growable: false);
  }

  Future<String?> pickRandomStudent(RecitationSession session) async {
    if (session.pendingStudentId != null) return null;
    final weights = <Student, int>{};
    for (final student in _students) {
      final w = pickWeightForStudent(session, student);
      if (w > 0) weights[student] = w;
    }
    if (weights.isEmpty) return null;

    final total = weights.values.fold<int>(0, (a, b) => a + b);
    var roll = Random().nextInt(total);
    Student? picked;
    for (final entry in weights.entries) {
      roll -= entry.value;
      if (roll < 0) {
        picked = entry.key;
        break;
      }
    }
    picked ??= weights.keys.first;

    final state = session.studentStates[picked.id];
    if (state == null) return null;
    if (state.outcome == CallOutcome.answered) {
      state.rewardClaimed = false;
    }
    state.outcome = CallOutcome.pending;
    session.pendingStudentId = picked.id;
    await _save();
    notifyListeners();
    return picked.id;
  }

  Future<void> markAnswered(RecitationSession session) async {
    final id = session.pendingStudentId;
    if (id == null) return;
    final state = session.studentStates[id];
    if (state == null) return;
    state.outcome = CallOutcome.answered;
    state.pointsEarned = session.pointsPerAnswer;
    session.pendingStudentId = null;
    await _save();
    notifyListeners();
  }

  Future<void> markNotAnswered(RecitationSession session) async {
    final id = session.pendingStudentId;
    if (id == null) return;
    final state = session.studentStates[id];
    if (state == null) return;
    state.outcome = CallOutcome.notAnswered;
    state.pointsEarned = 0;
    session.pendingStudentId = null;
    await _save();
    notifyListeners();
  }

  Future<bool> claimReward(RecitationSession session, String studentId) async {
    final state = session.studentStates[studentId];
    if (state == null || state.outcome != CallOutcome.answered) return false;
    if (state.rewardClaimed) return false;

    state.rewardClaimed = true;
    _ledger.add(
      PointLedgerEntry(
        id: _uuid.v4(),
        studentId: studentId,
        sessionId: session.id,
        sessionName: session.name,
        points: session.pointsPerAnswer,
        rewardLabel: session.rewardLabel,
        earnedAt: DateTime.now(),
      ),
    );
    await _save();
    notifyListeners();
    return true;
  }

  Future<File> _dataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/recitro_data.json');
  }

  Future<void> _load() async {
    final file = await _dataFile();
    if (!await file.exists()) return;
    final raw = await file.readAsString();
    if (raw.isEmpty) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    _students
      ..clear()
      ..addAll(
        (data['students'] as List<dynamic>? ?? [])
            .map((e) => Student.fromJson(e as Map<String, dynamic>)),
      );
    _sessions
      ..clear()
      ..addAll(
        (data['sessions'] as List<dynamic>? ?? [])
            .map((e) => RecitationSession.fromJson(e as Map<String, dynamic>)),
      );
    _ledger
      ..clear()
      ..addAll(
        (data['ledger'] as List<dynamic>? ?? [])
            .map((e) => PointLedgerEntry.fromJson(e as Map<String, dynamic>)),
      );
  }

  Future<void> _save() async {
    final file = await _dataFile();
    final payload = jsonEncode({
      'students': _students.map((s) => s.toJson()).toList(),
      'sessions': _sessions.map((s) => s.toJson()).toList(),
      'ledger': _ledger.map((e) => e.toJson()).toList(),
    });
    await file.writeAsString(payload);
  }
}