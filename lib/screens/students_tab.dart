import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/recitro_store.dart';
import '../models/call_outcome.dart';
import '../models/recitation_session.dart';
import '../models/student.dart';
import '../widgets/reward_center_dialog.dart';
import 'student_detail_screen.dart';

class StudentsTab extends StatelessWidget {
  const StudentsTab({super.key});

  Future<void> _confirmDelete(BuildContext context, Student student) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete student?'),
        content: Text(student.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<RecitroStore>().deleteStudent(student.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final store = context.watch<RecitroStore>();
    final students = store.students;

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          title: Text('Students'),
        ),
        if (students.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline_rounded,
                      size: 64, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('No students yet'),
                  SizedBox(height: 4),
                  Text('Tap Add in the sidebar'),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.separated(
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final student = students[index];
                final total = store.totalPointsForStudent(student.id);
                final unclaimed = _unclaimedCount(store, student.id);
                return Material(
                  color: Colors.white,
                  elevation: 2,
                  shadowColor: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              StudentDetailScreen(studentId: student.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                scheme.primary.withValues(alpha: 0.12),
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
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              student.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (unclaimed > 0)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: FilledButton.tonal(
                                onPressed: () => _claimNext(context, student.id),
                                child: Text('Claim ($unclaimed)'),
                              ),
                            ),
                          Tooltip(
                            message: 'Total points',
                            child: TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.stars_rounded,
                                  color: scheme.secondary),
                              label: Text(
                                '$total',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: () =>
                                _confirmDelete(context, student),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  int _unclaimedCount(RecitroStore store, String studentId) {
    var n = 0;
    for (final session in store.sessions) {
      final state = session.studentStates[studentId];
      if (store.canClaimReward(session, studentId)) {
        n++;
      }
    }
    return n;
  }

  Future<void> _claimNext(BuildContext context, String studentId) async {
    final store = context.read<RecitroStore>();
    RecitationSession? target;
    for (final session in store.sessions) {
      final state = session.studentStates[studentId];
      if (store.canClaimReward(session, studentId)) {
        target = session;
        break;
      }
    }
    if (target == null) return;
    final student = store.studentById(studentId);
    if (student == null) return;

    final state = target.studentStates[studentId]!;
    await showRewardCenterDialog(
      context: context,
      studentName: student.name,
      rewardLabel: target.rewardLabel,
      pointsEarned: state.pointsEarned,
      pointsRequired: target.pointsRequiredForReward,
      canClaim: true,
      onClaim: () => store.claimReward(target!, studentId),
    );
  }
}