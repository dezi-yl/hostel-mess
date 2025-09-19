import 'package:hostel_mess_2/core/domain/entities/food_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/room_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/student_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/student_food_record_entity.dart';
import 'package:hostel_mess_2/core/domain/repositories/student_repository_interface.dart';

class StudentOperationsUseCases {
  final StudentRepository repository;
  StudentOperationsUseCases(this.repository);

  // Add
  Future<int> addRoom(String name) => repository.addRoom(name);
  Future<int> addStudent(String name, String reg, {int? roomId}) =>
      repository.addStudent(name, reg, roomId);
  Future<int> addFood(String name) => repository.addFood(name);
  Future<int> addStudentFood(int studentId, int foodId, DateTime date) =>
      repository.addStudentFood(studentId, foodId, date);

  // Delete
  Future<int> deleteRoom(int id) => repository.deleteRoom(id);
  Future<int> deleteStudent(int id) => repository.deleteStudent(id);
  Future<int> deleteFood(int id) => repository.deleteFood(id);
  Future<int> deleteStudentFoodRecord(int recordId) =>
      repository.deleteStudentFoodRecord(recordId);

  // Get
  Future<List<StudentEntity>> getAllStudents() => repository.getAllStudents();
  Future<List<StudentEntity>> getAllStudentsInRoom(int roomId) =>
      repository.getAllStudentsInRoom(roomId);
  Future<List<FoodEntity>> getAllFood() => repository.getAllFood();
  Future<List<RoomEntity>> getAllRooms() => repository.getAllRooms();
  Future<List<StudentFoodRecordEntity>> getStudentsByDate(DateTime date) =>
      repository.getStudentsByDate(date);
}
