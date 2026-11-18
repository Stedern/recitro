import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/recitro_store.dart';
import '../models/recitation_session.dart';
import '../models/student.dart';

Future<void> showCallFlowDialog({
  required BuildContext context,
  required RecitationSession session,
  required Student student,
  required String sessionId,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return _CallFlowDialog(
        session: session,
        student: student,
        sessionId: sessionId,
      );
    },
  );
}

class _CallFlowDialog extends StatefulWidget {
  const _CallFlowDialog({
    required this.session,
    required this.student,
    required this.sessionId,
  });

  final RecitationSession session;
  final Student student;
  final String sessionId;

  @override
  State<_CallFlowDialog> createState() => _CallFlowDialogState();
}

class _CallFlowDialogState extends State<_CallFlowDialog> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToReward() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final store = context.read<RecitroStore>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 480),
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Called',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: scheme.outline,
                        ),
                  ),
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: scheme.primary.withValues(alpha: 0.12),
                    child: Text(
                      widget.student.name.isNotEmpty
                          ? widget.student.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.student.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final s = store.sessionById(widget.sessionId);
                            if (s != null) await store.markAnswered(s);
                            if (!context.mounted) return;
                            _goToReward();
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Answered'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final s = store.sessionById(widget.sessionId);
                            if (s != null) await store.markNotAnswered(s);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Not answered'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Reward',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: scheme.outline,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [scheme.secondary, scheme.tertiary],
                      ),
                    ),
                    child: const Icon(Icons.military_tech_rounded,
                        color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.session.rewardLabel,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.tertiary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars_rounded,
                          color: scheme.secondary, size: 32),
                      Text(
                        '+${widget.session.pointsPerAnswer}',
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You can claim later from Students.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.outline, fontSize: 13),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final s = store.sessionById(widget.sessionId);
                        if (s != null) {
                          await store.claimReward(s, widget.student.id);
                        }
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.handshake_rounded),
                      label: const Text('Claim now'),
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.secondary,
                        foregroundColor: scheme.onSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Skip for now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}