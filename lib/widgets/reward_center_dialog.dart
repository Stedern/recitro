import 'package:flutter/material.dart';

Future<void> showRewardCenterDialog({
  required BuildContext context,
  required String studentName,
  required String rewardLabel,
  required int points,
  required Future<void> Function() onClaim,
  bool alreadyClaimed = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stars_rounded, color: scheme.secondary, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '+$points',
                        style: Theme.of(dialogContext)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                if (alreadyClaimed)
                  Icon(Icons.verified_rounded, color: scheme.tertiary, size: 40)
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await onClaim();
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      icon: const Icon(Icons.handshake_rounded),
                      label: const Text('Claim'),
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.secondary,
                        foregroundColor: scheme.onSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}