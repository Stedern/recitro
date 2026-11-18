import 'call_outcome.dart';

class StudentSessionState {
  StudentSessionState({
    required this.studentId,
    this.outcome = CallOutcome.notCalled,
    this.pointsEarned = 0,
    this.rewardClaimed = false,
  });

  final String studentId;
  CallOutcome outcome;
  int pointsEarned;
  bool rewardClaimed;

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'outcome': outcome.name,
        'pointsEarned': pointsEarned,
        'rewardClaimed': rewardClaimed,
      };

  factory StudentSessionState.fromJson(Map<String, dynamic> json) =>
      StudentSessionState(
        studentId: json['studentId'] as String,
        outcome: CallOutcome.values.byName(json['outcome'] as String),
        pointsEarned: json['pointsEarned'] as int? ?? 0,
        rewardClaimed: json['rewardClaimed'] as bool? ?? false,
      );
}