import 'dart:math';
import 'package:hostel_mess_2/core/domain/entities/food_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/room_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/student_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/student_food_record_entity.dart';
import 'package:hostel_mess_2/core/domain/repositories/student_repository_interface.dart';

class MockStudentRepository implements StudentRepository {
  final List<RoomEntity> _rooms = [];
  final List<StudentEntity> _students = [];
  final List<FoodEntity> _foods = [];
  final List<StudentFoodRecordEntity> _studentFoodRecords = [];

  final Random _random = Random();

  // ✅ Add Operations
  @override
  Future<int> addRoom(String name) async {
    final newRoom = RoomEntity(id: _random.nextInt(1000), name: name);
    _rooms.add(newRoom);
    return newRoom.id;
  }

  @override
  Future<int> addStudent(String name, String reg, int? roomId) async {
    final newStudent = StudentEntity(id: _random.nextInt(1000), name: name, reg: reg, roomId: roomId);
    _students.add(newStudent);
    return newStudent.id;
  }

  @override
  Future<int> addFood(String name) async {
    final newFood = FoodEntity(id: _random.nextInt(1000), name: name);
    _foods.add(newFood);
    return newFood.id;
  }

  @override
  Future<int> addStudentFood(int studentId, int foodId, DateTime date) async {
    final student =
        _students.firstWhere((s) => s.id == studentId, orElse: () => StudentEntity(id: -1, name: "", reg: "", roomId: null));
    final food = _foods.firstWhere((f) => f.id == foodId, orElse: () => FoodEntity(id: -1, name: ""));

    if (student.id == -1 || food.id == -1) return 0; // Student or food not found

    final record = StudentFoodRecordEntity(
      studentName: student.name,
      foodName: food.name,
      date: date,
    );

    _studentFoodRecords.add(record);
    return 1; // Simulating success
  }

  // ✅ Delete Operations
  @override
  Future<int> deleteRoom(int id) async {
    int initialLength = _rooms.length;
    _rooms.removeWhere((room) => room.id == id);
    return _rooms.length < initialLength ? 1 : 0;
  }

  @override
  Future<int> deleteStudent(int id) async {
    int initialLength = _students.length;
    _students.removeWhere((student) => student.id == id);
    return _students.length < initialLength ? 1 : 0;
  }

  @override
  Future<int> deleteFood(int id) async {
    int initialLength = _foods.length;
    _foods.removeWhere((food) => food.id == id);
    return _foods.length < initialLength ? 1 : 0;
  }

  @override
  Future<int> deleteStudentFoodRecord(int recordId) async {
    if (recordId >= 0 && recordId < _studentFoodRecords.length) {
      _studentFoodRecords.removeAt(recordId);
      return 1;
    }
    return 0;
  }

  // ✅ Get Queries
  @override
  Future<List<StudentEntity>> getAllStudents() async {
    return List<StudentEntity>.from(_students);
  }

  @override
  Future<List<StudentEntity>> getAllStudentsInRoom(int roomId) async {
    return _students.where((student) => student.roomId == roomId).toList();
  }

  @override
  Future<List<FoodEntity>> getAllFood() async {
    return List<FoodEntity>.from(_foods);
  }

  @override
  Future<List<RoomEntity>> getAllRooms() async {
    return List<RoomEntity>.from(_rooms);
  }

  @override
  Future<List<StudentFoodRecordEntity>> getStudentsByDate(DateTime date) async {
    return _studentFoodRecords.where((record) {
      return record.date.year == date.year && record.date.month == date.month && record.date.day == date.day;
    }).toList();
  }
}
