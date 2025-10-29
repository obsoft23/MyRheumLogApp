// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myrheumlogapp/view/onboarding/onboard.dart';
import 'package:myrheumlogapp/view/tab_pages/home_tab/health_home.dart';
import 'package:myrheumlogapp/view/tab_pages/plan_tab/plan_home.dart';
import 'package:myrheumlogapp/view/themes/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const QuickLogView(),
    Center(child: Text('Meds Page')),
    Center(child: Text('Chat Page')),
    Center(child: Text('More Page')),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'app_logo',
              child: CircleAvatar(
                backgroundColor:
                    primaryBlue, // Replace 'Colors.red' with your desired color
                radius: 18,
                child: const Icon(Icons.favorite, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text(AppStrings.appName),
          ],
        ),
        centerTitle: false,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type:
            BottomNavigationBarType.fixed, // Ensures icons and text don't move
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            label: 'Quick Log',
          ),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble_2), label: 'Chat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_vert_outlined),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
