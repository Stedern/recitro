enum CallOutcome {
  notCalled,
  pending,
  answered,
  notAnswered;

  String get label => switch (this) {
        CallOutcome.notCalled => 'Not called',
        CallOutcome.pending => 'Awaiting response',
        CallOutcome.answered => 'Answered',
        CallOutcome.notAnswered => 'Not answered',
      };
}