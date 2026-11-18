import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/recitro_store.dart';
import '../models/call_outcome.dart';
import '../models/recitation_session.dart';
import '../widgets/call_flow_dialog.dart';
import '../widgets/reward_center_dialog.dart';

class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  bool _dialogOpen = false;

  int _infoBannerCount(RecitationSession session) {
    var n = 0;
    if (session.allowRecallUnanswered) n++;
    if (session.allowRecallAnswered) n++;
    return n;
  }

  Widget? _infoBannerAt(RecitationSession session, int index) {
    var cursor = 0;
    if (session.allowRecallUnanswered) {
      if (index == cursor) {
        return Card(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
          child: const ListTile(
            leading: Icon(Icons.replay_rounded),
            title: Text('Recall if not answered is on'),
            subtitle: Text(
              'Students who did not answer can be called again.',
            ),
          ),
        );
      }
      cursor++;
    }
    if (session.allowRecallAnswered) {
      if (index == cursor) {
        return Card(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
          child: const ListTile(
            leading: Icon(Icons.low_priority_rounded),
            title: Text('Recall if answered is on'),
            subtitle: Text(
              'Already-answered students can be called again with lower chance.',
            ),
          ),
        );
      }
    }
    return null;
  }

  Future<void> _openCallFlow(String studentId) async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    final store = context.read<RecitroStore>();
    final session = store.sessionById(widget.sessionId);
    final student = store.studentById(studentId);
    if (session == null || student == null) {
      _dialogOpen = false;
      return;
    }

    await showCallFlowDialog(
      context: context,
      session: session,
      student: student,
      sessionId: widget.sessionId,
    );
    _dialogOpen = false;
  }

  Future<void> _onCallPressed() async {
    final store = context.read<RecitroStore>();
    final session = store.sessionById(widget.sessionId);
    if (session == null || store.students.isEmpty) return;

    final pickedId = await store.pickRandomStudent(session);
    if (pickedId != null && mounted) {
      await _openCallFlow(pickedId);
    }
  }

  Future<void> _showReward(RecitroStore store, String studentId) async {
    final session = store.sessionById(widget.sessionId);
    final student = store.studentById(studentId);
    if (session == null || student == null) return;
    final state = session.studentStates[studentId];
    if (state == null || state.outcome != CallOutcome.answered) return;

    await showRewardCenterDialog(
      context: context,
      studentName: student.name,
      rewardLabel: session.rewardLabel,
      pointsEarned: state.pointsEarned,
      pointsRequired: session.pointsRequiredForReward,
      canClaim: store.canClaimReward(session, studentId),
      alreadyClaimed: state.rewardClaimed,
      onClaim: () => store.claimReward(session, studentId),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resumePendingCall());
  }

  void _resumePendingCall() {
    final session =
        context.read<RecitroStore>().sessionById(widget.sessionId);
    final pending = session?.pendingStudentId;
    if (pending != null) _openCallFlow(pending);
  }

  Color _accentFor(CallOutcome outcome, ColorScheme scheme) {
    return switch (outcome) {
      CallOutcome.answered => scheme.tertiary.withValues(alpha: 0.18),
      CallOutcome.notAnswered => scheme.error.withValues(alpha: 0.12),
      CallOutcome.pending => scheme.secondary.withValues(alpha: 0.22),
      CallOutcome.notCalled => Colors.white,
    };
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecitroStore>();
    final session = store.sessionById(widget.sessionId);
    final scheme = Theme.of(context).colorScheme;

    if (session == null) {
      return const Scaffold(body: Center(child: Icon(Icons.error_outline)));
    }

    final canCall =
        store.hasCallableStudents(session) && store.students.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.name),
        actions: [
          IconButton(
            tooltip: 'Delete session',
            onPressed: () async {
              await store.deleteSession(session.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: canCall ? _onCallPressed : null,
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        icon: const Icon(Icons.record_voice_over_rounded),
        label: const Text('Call'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        itemCount: store.students.length + _infoBannerCount(session),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final banner = _infoBannerAt(session, index);
          if (banner != null) return banner;
          final studentIndex = index - _infoBannerCount(session);
          final student = store.students[studentIndex];
          final state = session.studentStates[student.id];
          final outcome = state?.outcome ?? CallOutcome.notCalled;
          final canClaim = state != null &&
              store.canClaimReward(session, student.id);
          final accumulating = state != null &&
              outcome == CallOutcome.answered &&
              !state.rewardClaimed &&
              state.pointsEarned > 0;
          final showReward = accumulating || canClaim;

          return Material(
            color: _accentFor(outcome, scheme),
            elevation: 1,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: scheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        if (accumulating || canClaim)
                          Text(
                            '${state!.pointsEarned} / ${session.pointsRequiredForReward} pts',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.outline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (showReward && state != null)
                    IconButton(
                      tooltip: state.rewardClaimed
                          ? 'Reward claimed'
                          : 'Claim reward',
                      onPressed: () => _showReward(store, student.id),
                      style: IconButton.styleFrom(
                        backgroundColor: state.rewardClaimed
                            ? scheme.tertiary.withValues(alpha: 0.2)
                            : scheme.secondary.withValues(alpha: 0.35),
                      ),
                      icon: Icon(
                        state.rewardClaimed
                            ? Icons.verified_rounded
                            : Icons.redeem_rounded,
                        color: scheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}