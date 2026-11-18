class PointLedgerEntry {
  PointLedgerEntry({
    required this.id,
    required this.studentId,
    required this.sessionId,
    required this.sessionName,
    required this.points,
    required this.rewardLabel,
    required this.earnedAt,
  });

  final String id;
  final String studentId;
  final String sessionId;
  final String sessionName;
  final int points;
  final String rewardLabel;
  final DateTime earnedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'sessionId': sessionId,
        'sessionName': sessionName,
        'points': points,
        'rewardLabel': rewardLabel,
        'earnedAt': earnedAt.toIso8601String(),
      };

  factory PointLedgerEntry.fromJson(Map<String, dynamic> json) =>
      PointLedgerEntry(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        sessionId: json['sessionId'] as String,
        sessionName: json['sessionName'] as String,
        points: json['points'] as int,
        rewardLabel: json['rewardLabel'] as String,
        earnedAt: DateTime.parse(json['earnedAt'] as String),
      );
}