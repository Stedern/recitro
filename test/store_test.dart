import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:recitro/data/recitro_store.dart';
import 'package:recitro/models/call_outcome.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '.';
}

Future<void> _answerOnce(RecitroStore store, String sessionId) async {
  final session = store.sessionById(sessionId)!;
  await store.pickRandomStudent(session);
  await store.markAnswered(store.sessionById(sessionId)!);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  test('ledger keeps points after session deleted', () async {
    final store = RecitroStore();
    await store.addStudent('Ada');
    await store.addSession(
      name: 'Quiz',
      pointsPerAnswer: 5,
      pointsRequiredForReward: 5,
      rewardLabel: 'Star',
      allowRecallUnanswered: false,
      allowRecallAnswered: false,
    );
    final session = store.sessions.first;
    final studentId = store.students.first.id;
    await _answerOnce(store, session.id);
    await store.claimReward(store.sessionById(session.id)!, studentId);

    expect(store.totalPointsForStudent(studentId), 5);
    await store.deleteSession(session.id);
    expect(store.totalPointsForStudent(studentId), 5);
    expect(store.sessions, isEmpty);
  });

  test('answered without claim has no ledger points', () async {
    final store = RecitroStore();
    await store.addStudent('Bo');
    await store.addSession(
      name: 'Drill',
      pointsPerAnswer: 3,
      pointsRequiredForReward: 10,
      rewardLabel: 'Badge',
      allowRecallUnanswered: true,
      allowRecallAnswered: false,
    );
    final session = store.sessions.first;
    final studentId = store.students.first.id;
    await _answerOnce(store, session.id);

    expect(store.totalPointsForStudent(studentId), 0);
    final state = store.sessionById(session.id)!.studentStates[studentId];
    expect(state?.outcome, CallOutcome.answered);
    expect(state?.pointsEarned, 3);
    expect(state?.rewardClaimed, false);
    expect(store.canClaimReward(store.sessionById(session.id)!, studentId),
        isFalse);
  });

  test('points accumulate across recalls until threshold', () async {
    final store = RecitroStore();
    await store.addStudent('Cal');
    await store.addSession(
      name: 'Recall',
      pointsPerAnswer: 5,
      pointsRequiredForReward: 10,
      rewardLabel: 'Candy',
      allowRecallUnanswered: false,
      allowRecallAnswered: true,
    );
    final session = store.sessions.first;
    final studentId = store.students.first.id;

    await _answerOnce(store, session.id);
    var s = store.sessionById(session.id)!;
    expect(s.studentStates[studentId]!.pointsEarned, 5);
    expect(store.canClaimReward(s, studentId), isFalse);

    await store.pickRandomStudent(s);
    await store.markAnswered(store.sessionById(session.id)!);
    s = store.sessionById(session.id)!;
    expect(s.studentStates[studentId]!.pointsEarned, 10);
    expect(store.canClaimReward(s, studentId), isTrue);

    await store.claimReward(s, studentId);
    expect(store.totalPointsForStudent(studentId), 10);
  });

  test('claim blocked below threshold', () async {
    final store = RecitroStore();
    await store.addStudent('Dee');
    await store.addSession(
      name: 'S',
      pointsPerAnswer: 5,
      pointsRequiredForReward: 10,
      rewardLabel: 'R',
      allowRecallUnanswered: false,
      allowRecallAnswered: false,
    );
    final session = store.sessions.first;
    final studentId = store.students.first.id;
    await _answerOnce(store, session.id);

    final ok =
        await store.claimReward(store.sessionById(session.id)!, studentId);
    expect(ok, isFalse);
    expect(store.totalPointsForStudent(studentId), 0);
  });

  test('answered recall uses lower pick weight', () async {
    final store = RecitroStore();
    await store.addStudent('A');
    await store.addSession(
      name: 'S',
      pointsPerAnswer: 1,
      pointsRequiredForReward: 1,
      rewardLabel: 'R',
      allowRecallUnanswered: false,
      allowRecallAnswered: true,
    );
    final session = store.sessions.first;
    final a = store.students.first.id;
    await _answerOnce(store, session.id);
    await store.claimReward(store.sessionById(session.id)!, a);

    await store.addStudent('B');
    final fresh = store.sessionById(session.id)!;
    final b = store.students[1].id;

    expect(
      store.pickWeightForStudent(fresh, store.studentById(a)!),
      RecitroStore.answeredRecallPickWeight,
    );
    expect(
      store.pickWeightForStudent(fresh, store.studentById(b)!),
      RecitroStore.primaryPickWeight,
    );
    expect(
      store.pickWeightForStudent(fresh, store.studentById(b)!),
      greaterThan(store.pickWeightForStudent(fresh, store.studentById(a)!)),
    );
  });
}