import 'package:hostel_mess_2/core/domain/entities/food_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/room_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/student_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/student_food_record_entity.dart';
import 'package:hostel_mess_2/core/domain/repositories/student_repository_interface.dart';

class StudentOperationsUseCases {
  final StudentRepository repository;
  StudentOperationsUseCases(this.repository);

  // ✅ Add
  Future<int> addRoom(String name) async {
    try {
      return await repository.addRoom(name);
    } catch (e) {
      throw Exception("Failed to add room: $e");
    }
  }

  Future<int> addStudent(String name, String reg, {int? roomId}) async {
    try {
      return await repository.addStudent(name, reg, roomId);
    } catch (e) {
      throw Exception("Failed to add student: $e");
    }
  }

  Future<int> addFood(String name) async {
    try {
      return await repository.addFood(name);
    } catch (e) {
      throw Exception("Failed to add food: $e");
    }
  }

  Future<int> addStudentFood(int studentId, int foodId, DateTime date) async {
    try {
      return await repository.addStudentFood(studentId, foodId, date);
    } catch (e) {
      throw Exception("Failed to add student food record: $e");
    }
  }

  // ✅ Delete
  Future<int> deleteRoom(int id) async {
    try {
      return await repository.deleteRoom(id);
    } catch (e) {
      throw Exception("Failed to delete room: $e");
    }
  }

  Future<int> deleteStudent(int id) async {
    try {
      return await repository.deleteStudent(id);
    } catch (e) {
      throw Exception("Failed to delete student: $e");
    }
  }

  Future<int> deleteFood(int id) async {
    try {
      return await repository.deleteFood(id);
    } catch (e) {
      throw Exception("Failed to delete food: $e");
    }
  }

  Future<int> deleteStudentFoodRecord(int recordId) async {
    try {
      return await repository.deleteStudentFoodRecord(recordId);
    } catch (e) {
      throw Exception("Failed to delete student food record: $e");
    }
  }

  // ✅ Get
  Future<List<StudentEntity>> getAllStudents() async {
    try {
      return await repository.getAllStudents();
    } catch (e) {
      throw Exception("Failed to fetch students: $e");
    }
  }

  Future<List<StudentEntity>> getAllStudentsInRoom(int roomId) async {
    try {
      return await repository.getAllStudentsInRoom(roomId);
    } catch (e) {
      throw Exception("Failed to fetch students in room $roomId: $e");
    }
  }

  Future<List<FoodEntity>> getAllFood() async {
    try {
      return await repository.getAllFood();
    } catch (e) {
      throw Exception("Failed to fetch food: $e");
    }
  }

  Future<List<RoomEntity>> getAllRooms() async {
    try {
      return await repository.getAllRooms();
    } catch (e) {
      throw Exception("Failed to fetch rooms: $e");
    }
  }

  Future<List<StudentFoodRecordEntity>> getStudentsByDate(DateTime date) async {
    try {
      return await repository.getStudentsByDate(date);
    } catch (e) {
      throw Exception("Failed to fetch students by date $date: $e");
    }
  }
}
