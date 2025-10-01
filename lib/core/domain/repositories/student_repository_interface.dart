import 'package:hostel_mess_2/core/domain/entities/food_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/room_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/student_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/student_food_record_entity.dart';

abstract class StudentRepository {
  // ✅ Add Operations
  Future<int> addRoom(String name);
  Future<int> addStudent(String name, String reg, int? roomId);
  Future<int> addFood(String name);
  Future<int> addStudentFood(int studentId, int foodId, DateTime date);

  // ✅ Delete Operations
  Future<int> deleteRoom(int id);
  Future<int> deleteStudent(int id);
  Future<int> deleteFood(int id);
  Future<int> deleteStudentFoodRecord(int recordId);

  // ✅ Get Queries
  Future<List<StudentEntity>> getAllStudents();
  Future<List<StudentEntity>> getAllStudentsInRoom(int roomId);
  Future<List<FoodEntity>> getAllFood();
  Future<List<RoomEntity>> getAllRooms();

  /// Get students who ate on a specific **date**
  Future<List<StudentFoodRecordEntity>> getStudentsByDate(DateTime date);
}
