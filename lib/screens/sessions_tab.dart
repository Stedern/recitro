import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/recitro_store.dart';
import '../models/recitation_session.dart';
import 'session_detail_screen.dart';

class SessionsTab extends StatelessWidget {
  const SessionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sessions = context.watch<RecitroStore>().sessions;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text('Sessions'),
        ),
        if (sessions.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox_rounded, size: 64, color: Colors.black26),
                  const SizedBox(height: 12),
                  Text(
                    'No sessions yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap Add in the sidebar',
                    style: TextStyle(color: scheme.outline),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.separated(
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _SessionCard(session: session);
              },
            ),
          ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final RecitationSession session;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: scheme.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SessionDetailScreen(sessionId: session.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.tertiary],
                  ),
                ),
                child: const Icon(Icons.mic_rounded, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.military_tech_outlined,
                            size: 16, color: scheme.tertiary),
                        const SizedBox(width: 4),
                        Text(session.rewardLabel,
                            style: TextStyle(color: scheme.tertiary)),
                        const SizedBox(width: 12),
                        Icon(Icons.stars_rounded,
                            size: 16, color: scheme.secondary),
                        Text('+${session.pointsPerAnswer}',
                            style: TextStyle(color: scheme.secondary)),
                      ],
                    ),
                    if (session.allowRecallUnanswered ||
                        session.allowRecallAnswered) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (session.allowRecallUnanswered)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              label: const Text('Recall unanswered'),
                            ),
                          if (session.allowRecallAnswered)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              label: const Text('Low-chance recall answered'),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}