import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/recitro_store.dart';
import '../models/call_outcome.dart';
import '../models/recitation_session.dart';

class StudentDetailScreen extends StatelessWidget {
  const StudentDetailScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecitroStore>();
    final student = store.studentById(studentId);
    final scheme = Theme.of(context).colorScheme;

    if (student == null) {
      return const Scaffold(body: Center(child: Icon(Icons.error_outline)));
    }

    final total = store.totalPointsForStudent(studentId);
    final history = store.ledgerForStudent(studentId);

    final pendingClaims = <_PendingClaim>[];
    for (final session in store.sessions) {
      final state = session.studentStates[studentId];
      if (state != null &&
          state.outcome == CallOutcome.answered &&
          !state.rewardClaimed) {
        pendingClaims.add(_PendingClaim(session));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primary, scheme.tertiary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total points',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(Icons.stars_rounded, size: 56, color: scheme.secondary),
                  const SizedBox(height: 8),
                  Text(
                    '$total',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (pendingClaims.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Unclaimed rewards',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          if (pendingClaims.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverList.separated(
                itemCount: pendingClaims.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final item = pendingClaims[i];
                  final session = item.session;
                  return FilledButton.icon(
                    onPressed: () async {
                      await store.claimReward(session, studentId);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.secondary,
                      foregroundColor: scheme.onSecondary,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.redeem_rounded),
                    label: Text(
                        'Claim ${session.rewardLabel} (+${session.pointsPerAnswer})'),
                  );
                },
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            sliver: SliverList.separated(
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = history[index];
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Icon(Icons.military_tech_rounded, color: scheme.tertiary),
                  title: Text(entry.sessionName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(entry.rewardLabel),
                  trailing: Text(
                    '+${entry.points}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: scheme.secondary,
                      fontSize: 18,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingClaim {
  _PendingClaim(this.session);
  final RecitationSession session;
}