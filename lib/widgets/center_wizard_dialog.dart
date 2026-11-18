import 'package:flutter/material.dart';

typedef WizardStepBuilder = Widget Function(
  BuildContext context,
  void Function() next,
  void Function() back,
);

Future<bool?> showCenterWizardDialog({
  required BuildContext context,
  required List<WizardStepBuilder> steps,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return _CenterWizardDialog(steps: steps);
    },
  );
}

class _CenterWizardDialog extends StatefulWidget {
  const _CenterWizardDialog({required this.steps});

  final List<WizardStepBuilder> steps;

  @override
  State<_CenterWizardDialog> createState() => _CenterWizardDialogState();
}

class _CenterWizardDialogState extends State<_CenterWizardDialog> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < widget.steps.length - 1) {
      setState(() => _page++);
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _back() {
    if (_page > 0) {
      setState(() => _page--);
      _controller.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Material(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.primary.withValues(alpha: 0.85)],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(widget.steps.length, (i) {
                          final active = i == _page;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 6),
                            width: active ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: active
                                  ? scheme.secondary
                                  : scheme.onPrimary.withValues(alpha: 0.35),
                            ),
                          );
                        }),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: Icon(Icons.close, color: scheme.onPrimary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.steps.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: widget.steps[index](context, _next, _back),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}