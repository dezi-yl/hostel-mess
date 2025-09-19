import 'package:hostel_mess_2/core/data/datasources/local/database_helper.dart';
import 'package:hostel_mess_2/core/domain/entities/food_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/room_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/student_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/student_food_record_entity.dart';
import 'package:hostel_mess_2/core/domain/repositories/student_repository_interface.dart';

class StudentRepositoryImpl implements StudentRepository {
  final LocalDatabaseHelper dbHelper;

  StudentRepositoryImpl(this.dbHelper);

  // ✅ Add Operations
  @override
  Future<int> addRoom(String name) => dbHelper.addRoom(name);

  @override
  Future<int> addStudent(String name, String reg, int? roomId) =>
      dbHelper.addStudent(name, reg, roomId);

  @override
  Future<int> addFood(String name) => dbHelper.addFood(name);

  @override
  Future<int> addStudentFood(int studentId, int foodId, DateTime date) =>
      dbHelper.addStudentFoodRecord(studentId, foodId, date);

  // ✅ Delete Operations
  @override
  Future<int> deleteRoom(int id) => dbHelper.deleteRoom(id);

  @override
  Future<int> deleteStudent(int id) => dbHelper.deleteStudent(id);

  @override
  Future<int> deleteFood(int id) => dbHelper.deleteFood(id);

  @override
  Future<int> deleteStudentFoodRecord(int recordId) =>
      dbHelper.deleteStudentFoodRecord(recordId);

  // ✅ Get all students
  @override
  Future<List<StudentEntity>> getAllStudents() async {
    final data = await dbHelper.getAllStudents();
    return data.map((e) => StudentEntity(
          id: e['id'],
          name: e['name'],
          reg: e['reg'],
          roomId: e['room_id'],
        )).toList();
  }

  // ✅ Get students in a specific room
  @override
  Future<List<StudentEntity>> getAllStudentsInRoom(int roomId) async {
    final data = await dbHelper.getAllStudentsInRoom(roomId);
    return data.map((e) => StudentEntity(
          id: e['id'],
          name: e['name'],
          reg: e['reg'],
          roomId: e['room_id'],
        )).toList();
  }

  // ✅ Get all food items
  @override
  Future<List<FoodEntity>> getAllFood() async {
    final data = await dbHelper.getAllFood();
    return data.map((e) => FoodEntity(
          id: e['id'],
          name: e['name'],
        )).toList();
  }

  // ✅ Get all rooms
  @override
  Future<List<RoomEntity>> getAllRooms() async {
    final data = await dbHelper.getAllRooms();
    return data.map((e) => RoomEntity(
          id: e['id'],
          name: e['name'],
        )).toList();
  }

  // ✅ Get students who ate on a specific date
  @override
  Future<List<StudentFoodRecordEntity>> getStudentsByDate(DateTime date) async {
    final data = await dbHelper.getStudentMealsOnDate(date);
    return data.map((e) => StudentFoodRecordEntity(
          studentName: e['name'],
          foodName: e['food_name'],
          date: DateTime.fromMillisecondsSinceEpoch(e['date']),
        )).toList();
  }
}