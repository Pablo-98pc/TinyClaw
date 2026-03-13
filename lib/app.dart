import 'package:flutter/material.dart';
import 'views/chat/chat_screen.dart';
import 'views/tasks/tasks_screen.dart';
import 'views/events/events_screen.dart';
import 'views/components/tc_nav_bar.dart';
import 'views/theme/theme.dart';

class TinyClawApp extends StatelessWidget {
  const TinyClawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TinyClaw',
      theme: TcTheme.dark(),
      darkTheme: TcTheme.dark(),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    ChatScreen(),
    TasksScreen(),
    EventsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: TcNavBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
