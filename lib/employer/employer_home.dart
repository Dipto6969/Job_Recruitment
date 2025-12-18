import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'employer_dashboard.dart';
import 'employer_profile_screen.dart';

class EmployerHome extends StatefulWidget {
  const EmployerHome({Key? key}) : super(key: key);

  @override
  State<EmployerHome> createState() => _EmployerHomeState();
}

class _EmployerHomeState extends State<EmployerHome> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const EmployerDashboard(),
    const EmployerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}