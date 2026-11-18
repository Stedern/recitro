import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/recitro_store.dart';
import '../models/recitation_session.dart';
import '../widgets/center_wizard_dialog.dart';
import 'session_detail_screen.dart';

class SessionsTab extends StatelessWidget {
  const SessionsTab({super.key});

  Future<void> _createSessionWizard(BuildContext context) async {
    final nameController = TextEditingController();
    final rewardController = TextEditingController(text: 'Star');
    final pointsController = TextEditingController(text: '1');
    var allowRecall = false;
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
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge_outlined),
                    hintText: 'Title',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? '' : null,
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setLocal) {
                    return SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: allowRecall,
                      onChanged: (v) =>
                          setLocal(() => allowRecall = v),
                      secondary: const Icon(Icons.replay_rounded),
                      title: const SizedBox.shrink(),
                    );
                  },
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) next();
                    },
                    child: const Icon(Icons.arrow_forward_rounded),
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
              TextFormField(
                controller: rewardController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.military_tech_outlined),
                  hintText: 'Reward',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.stars_rounded),
                  hintText: 'Points',
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: back,
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Icon(Icons.check_rounded),
                  ),
                ],
              ),
            ],
          );
        },
      ],
    );

    if (ok == true && context.mounted) {
      final points = int.tryParse(pointsController.text) ?? 1;
      await context.read<RecitroStore>().addSession(
            name: nameController.text,
            pointsPerAnswer: points,
            rewardLabel: rewardController.text.trim().isEmpty
                ? 'Reward'
                : rewardController.text.trim(),
            allowRecallUnanswered: allowRecall,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sessions = context.watch<RecitroStore>().sessions;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text('Sessions'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.tonal(
                onPressed: () => _createSessionWizard(context),
                style: FilledButton.styleFrom(
                  foregroundColor: scheme.primary,
                  backgroundColor: scheme.secondary.withValues(alpha: 0.25),
                ),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            ),
          ],
        ),
        if (sessions.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Icon(Icons.inbox_rounded, size: 64, color: Colors.black26)),
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