import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/recitro_store.dart';
import '../models/student.dart';
import 'student_detail_screen.dart';

class StudentsTab extends StatelessWidget {
  const StudentsTab({super.key});

  Future<void> _showAddStudent(BuildContext context) async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    hintText: 'Name',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? '' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          Navigator.pop(ctx, true);
                        }
                      },
                      child: const Icon(Icons.check_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true && context.mounted) {
      await context.read<RecitroStore>().addStudent(nameController.text);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Student student) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Icon(Icons.close_rounded),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Icon(Icons.delete_outline_rounded),
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
        SliverAppBar(
          floating: true,
          title: const Text('Students'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.tonal(
                onPressed: () => _showAddStudent(context),
                style: FilledButton.styleFrom(
                  foregroundColor: scheme.primary,
                  backgroundColor: scheme.secondary.withValues(alpha: 0.25),
                ),
                child: const Icon(Icons.person_add_rounded, size: 28),
              ),
            ),
          ],
        ),
        if (students.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Icon(Icons.people_outline_rounded, size: 64, color: Colors.black26)),
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
                          IconButton(
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (ctx) => Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.stars_rounded,
                                            size: 48, color: scheme.secondary),
                                        const SizedBox(height: 12),
                                        Text(
                                          '$total',
                                          style: Theme.of(ctx)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: scheme.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: Badge(
                              label: Text('$total'),
                              isLabelVisible: total > 0,
                              child: Icon(Icons.stars_rounded,
                                  color: scheme.secondary),
                            ),
                          ),
                          IconButton(
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
}