import 'student_session_state.dart';

class RecitationSession {
  RecitationSession({
    required this.id,
    required this.name,
    required this.pointsPerAnswer,
    required this.rewardLabel,
    required this.allowRecallUnanswered,
    required this.studentStates,
    this.pendingStudentId,
  });

  final String id;
  String name;
  int pointsPerAnswer;
  String rewardLabel;
  bool allowRecallUnanswered;
  Map<String, StudentSessionState> studentStates;
  String? pendingStudentId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'pointsPerAnswer': pointsPerAnswer,
        'rewardLabel': rewardLabel,
        'allowRecallUnanswered': allowRecallUnanswered,
        'pendingStudentId': pendingStudentId,
        'studentStates': studentStates.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      };

  factory RecitationSession.fromJson(Map<String, dynamic> json) =>
      RecitationSession(
        id: json['id'] as String,
        name: json['name'] as String,
        pointsPerAnswer: json['pointsPerAnswer'] as int,
        rewardLabel: (json['rewardLabel'] as String?) ?? 'Reward',
        allowRecallUnanswered: json['allowRecallUnanswered'] as bool,
        pendingStudentId: json['pendingStudentId'] as String?,
        studentStates: (json['studentStates'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            StudentSessionState.fromJson(value as Map<String, dynamic>),
          ),
        ),
      );
}