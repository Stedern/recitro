import 'package:flutter/material.dart';

Future<void> showRewardCenterDialog({
  required BuildContext context,
  required String studentName,
  required String rewardLabel,
  required int pointsEarned,
  required int pointsRequired,
  required bool canClaim,
  required Future<void> Function() onClaim,
  bool alreadyClaimed = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      final until = (pointsRequired - pointsEarned).clamp(0, pointsRequired);
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [scheme.secondary, scheme.tertiary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.secondary.withValues(alpha: 0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(Icons.military_tech_rounded,
                      color: scheme.onSecondary, size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  studentName,
                  style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  rewardLabel,
                  style: Theme.of(dialogContext).textTheme.headlineSmall?.copyWith(
                        color: scheme.tertiary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Session points: $pointsEarned / $pointsRequired',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (pointsEarned / pointsRequired).clamp(0.0, 1.0),
                  backgroundColor: scheme.primary.withValues(alpha: 0.1),
                  color: scheme.secondary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
                if (!alreadyClaimed && !canClaim) ...[
                  const SizedBox(height: 12),
                  Text(
                    '$until more point(s) needed to claim.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.outline, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 28),
                if (alreadyClaimed)
                  Icon(Icons.verified_rounded, color: scheme.tertiary, size: 40)
                else ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: canClaim
                          ? () async {
                              await onClaim();
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                            }
                          : null,
                      icon: const Icon(Icons.handshake_rounded),
                      label: Text(
                        canClaim
                            ? 'Claim reward ($pointsEarned pts)'
                            : 'Need $until more pts',
                      ),
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
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}