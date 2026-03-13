import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/briefing_provider.dart';
import 'views/chat/chat_screen.dart';
import 'views/tasks/tasks_screen.dart';
import 'views/notes/notes_screen.dart';
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

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    ChatScreen(),
    TasksScreen(),
    NotesScreen(),
    EventsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(briefingProvider);
    }
  }

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
