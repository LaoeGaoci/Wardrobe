import 'package:flutter/material.dart';

import '../friends/friends_page.dart';
import '../profile/profile.dart';
import 'wardrobe_page.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const WardrobePage(),
      const FriendsPage(),
      ProfilePage(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined),
            selectedIcon: Icon(Icons.checkroom),
            label: '衣柜',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: '好友',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}