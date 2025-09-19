import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostel_mess_2/core/di/dependency_injection.dart';
import 'package:hostel_mess_2/core/domain/usecases/student_repo_usecase.dart';
import 'package:hostel_mess_2/features/home_page/nav_bar_screen.dart';
import 'package:hostel_mess_2/features/home_page/pages/students_page/bloc/students_page_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // setup GetIt DI
  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => StudentBloc(locator<StudentOperationsUseCases>())
            ..add(const LoadStudentsEvent()), // preload students
        ),
        // Later: RoomsBloc, FoodBloc, ReportsBloc
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hotel Mess',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const NavBarScreen(), // ✅ NavBar with all 4 pages
      ),
    );
  }
}
