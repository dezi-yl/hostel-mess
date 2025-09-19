import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostel_mess_2/core/di/dependency_injection.dart';
import 'package:hostel_mess_2/core/domain/usecases/student_repo_usecase.dart';
import 'package:hostel_mess_2/features/home_page/pages/food_page.dart';
import 'package:hostel_mess_2/features/home_page/pages/reports_page.dart';
import 'package:hostel_mess_2/features/home_page/pages/rooms_page.dart';
import 'package:hostel_mess_2/features/home_page/pages/students_page/bloc/students_page_bloc.dart';
import 'package:hostel_mess_2/features/home_page/pages/students_page/students_page.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        // ✅ StudentsPage wrapped with StudentBloc
        BlocProvider(
          create: (_) =>
              StudentBloc(locator<StudentOperationsUseCases>())
                ..add(const LoadStudentsEvent()),
          child: const StudentsPage(),
        ),

        // ✅ RoomsPage will get RoomsBloc later
        const RoomsPage(),

        // ✅ FoodPage will get FoodBloc later
        const FoodPage(),

        // ✅ ReportsPage will get ReportsBloc later
        const ReportsPage(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: "Rooms"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Food & Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
        ],
      ),
    );
  }
}
