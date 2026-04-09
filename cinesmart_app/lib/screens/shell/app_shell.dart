import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../movies/movies_screen.dart';
import '../events/events_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      const MoviesScreen(),
      const EventsScreen(),
      const _PlaceholderScreen(title: 'Profile'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.movie_outlined), label: 'Movies'),
          NavigationDestination(
              icon: Icon(Icons.local_activity_outlined), label: 'Events'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

