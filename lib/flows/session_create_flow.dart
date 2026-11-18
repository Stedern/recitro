import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/recitro_store.dart';
import '../widgets/center_wizard_dialog.dart';

Future<void> showSessionCreateFlow(BuildContext context) async {
  final nameController = TextEditingController();
  final rewardController = TextEditingController(text: 'Star');
  final pointsController = TextEditingController(text: '5');
  final thresholdController = TextEditingController(text: '10');
  var allowRecallUnanswered = false;
  var allowRecallAnswered = false;
  final formKey = GlobalKey<FormState>();

  final ok = await showCenterWizardDialog(
    context: context,
    steps: [
      (ctx, next, back) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Session',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Session name',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setLocal) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: allowRecallUnanswered,
                    onChanged: (v) =>
                        setLocal(() => allowRecallUnanswered = v),
                    title: const Text('Recall if not answered'),
                    subtitle: const Text(
                      'Students marked not answered can be called again in this session.',
                    ),
                    secondary: const Icon(Icons.replay_rounded),
                  );
                },
              ),
              StatefulBuilder(
                builder: (context, setLocal) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: allowRecallAnswered,
                    onChanged: (v) => setLocal(() => allowRecallAnswered = v),
                    title: const Text('Recall if answered'),
                    subtitle: const Text(
                      'Already-answered students can be called again, with a lower chance.',
                    ),
                    secondary: const Icon(Icons.low_priority_rounded),
                  );
                },
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) next();
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next'),
                ),
              ),
            ],
          ),
        );
      },
      (ctx, next, back) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reward',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: rewardController,
              decoration: const InputDecoration(
                labelText: 'Reward name',
                prefixIcon: Icon(Icons.military_tech_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Points per answer',
                helperText: 'Added each time the student answers correctly.',
                prefixIcon: Icon(Icons.add_circle_outline_rounded),
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 1) return 'Min 1';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: thresholdController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Points needed to claim reward',
                helperText: 'Example: 5 per answer, 10 needed → two correct answers.',
                prefixIcon: Icon(Icons.stars_rounded),
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 1) return 'Min 1';
                return null;
              },
            ),
            const Spacer(),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: back,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {
                    final per = int.tryParse(pointsController.text) ?? 0;
                    final need = int.tryParse(thresholdController.text) ?? 0;
                    if (per < 1 || need < 1) return;
                    Navigator.of(ctx).pop(true);
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Create'),
                ),
              ],
            ),
          ],
        );
      },
    ],
  );

  if (ok == true && context.mounted) {
    final points = int.tryParse(pointsController.text) ?? 5;
    final threshold = int.tryParse(thresholdController.text) ?? 10;
    await context.read<RecitroStore>().addSession(
          name: nameController.text,
          pointsPerAnswer: points,
          pointsRequiredForReward: threshold,
          rewardLabel: rewardController.text.trim().isEmpty
              ? 'Reward'
              : rewardController.text.trim(),
          allowRecallUnanswered: allowRecallUnanswered,
          allowRecallAnswered: allowRecallAnswered,
        );
  }
}