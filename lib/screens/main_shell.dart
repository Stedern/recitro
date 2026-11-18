import 'package:flutter/material.dart';

import '../flows/session_create_flow.dart';
import '../flows/student_create_flow.dart';
import 'sessions_tab.dart';
import 'students_tab.dart';

enum ShellSection { sessions, students }

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  ShellSection _section = ShellSection.sessions;

  Future<void> _onAdd() async {
    switch (_section) {
      case ShellSection.sessions:
        await showSessionCreateFlow(context);
      case ShellSection.students:
        await showStudentCreateFlow(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final extended = MediaQuery.sizeOf(context).width > 720;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            backgroundColor: scheme.primary,
            selectedIndex: _section.index,
            onDestinationSelected: (i) {
              if (i == 2) {
                _onAdd();
                return;
              }
              setState(() => _section = ShellSection.values[i]);
            },
            leading: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child:
                  Icon(Icons.school_rounded, color: scheme.secondary, size: 32),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.auto_stories_outlined),
                selectedIcon: Icon(Icons.auto_stories_rounded),
                label: Text('Sessions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline_rounded),
                selectedIcon: Icon(Icons.people_rounded),
                label: Text('Students'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_circle_outline_rounded),
                selectedIcon: Icon(Icons.add_circle_rounded),
                label: Text('Add'),
              ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: IndexedStack(
              index: _section.index,
              children: const [
                SessionsTab(),
                StudentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}