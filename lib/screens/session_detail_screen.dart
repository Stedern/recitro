import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/recitro_store.dart';
import '../models/call_outcome.dart';
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
      points: session.pointsPerAnswer,
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

    final canCall = store.eligibleStudents(session).isNotEmpty &&
        session.pendingStudentId == null &&
        store.students.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.name),
        actions: [
          IconButton(
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
        itemCount: store.students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final student = store.students[index];
          final state = session.studentStates[student.id];
          final outcome = state?.outcome ?? CallOutcome.notCalled;
          final showReward = outcome == CallOutcome.answered;

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
                    child: Text(
                      student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (showReward)
                    IconButton(
                      onPressed: () => _showReward(store, student.id),
                      style: IconButton.styleFrom(
                        backgroundColor: state!.rewardClaimed
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