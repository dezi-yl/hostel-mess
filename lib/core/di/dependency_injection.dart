import 'package:get_it/get_it.dart';
import 'package:hostel_mess_2/core/data/datasources/local/database_helper.dart';
import 'package:hostel_mess_2/core/data/datasources/local/sqlite_database_helper.dart';
// ignore: unused_import
import 'package:hostel_mess_2/core/data/repositories/mock_student_repo_impl.dart';
import 'package:hostel_mess_2/core/data/repositories/student_repo_impl.dart';
import 'package:hostel_mess_2/core/domain/repositories/student_repository_interface.dart';
import 'package:hostel_mess_2/core/domain/usecases/student_repo_usecase.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // ✅ Database Helper
  locator.registerLazySingleton<LocalDatabaseHelper>(() => SQLiteLocalDatabaseHelper());

  // ✅ Repository
  locator.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(locator<LocalDatabaseHelper>()),
  );
  // locator.registerLazySingleton<StudentRepository>(() => MockStudentRepository());

  // ✅ Use Cases
  locator.registerLazySingleton<StudentOperationsUseCases>(
    () => StudentOperationsUseCases(locator<StudentRepository>()),
  );
}
