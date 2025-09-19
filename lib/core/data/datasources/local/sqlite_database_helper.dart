import 'package:hostel_mess_2/core/data/datasources/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteLocalDatabaseHelper implements LocalDatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      String path = join(await getDatabasesPath(), 'hostel_mess.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE room (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              name TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE student (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              reg TEXT UNIQUE NOT NULL,
              room_id INTEGER,
              FOREIGN KEY (room_id) REFERENCES room (id) ON DELETE SET NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE food (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              name TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE student_food (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              student_id INTEGER NOT NULL,
              food_id INTEGER NOT NULL,
              date INTEGER NOT NULL,
              FOREIGN KEY (student_id) REFERENCES student (id) ON DELETE CASCADE,
              FOREIGN KEY (food_id) REFERENCES food (id) ON DELETE CASCADE
            )
          ''');
        },
      );
    } catch (e) {
      print("❌ DB Init Error: $e");
      rethrow; // You might want to handle this differently
    }
  }

  // ---------- Safe CRUD Methods ----------

  @override
  Future<int> addRoom(String name) async {
    try {
      final db = await database;
      return await db.insert('room', {'name': name});
    } catch (e) {
      print("❌ addRoom error: $e");
      return -1;
    }
  }

  @override
  Future<int> addStudent(String name, String reg, int? roomId) async {
    try {
      final db = await database;
      return await db.insert('student', {'name': name, 'reg': reg, 'room_id': roomId});
    } catch (e) {
      print("❌ addStudent error: $e");
      return -1;
    }
  }

  @override
  Future<int> addFood(String name) async {
    try {
      final db = await database;
      return await db.insert('food', {'name': name});
    } catch (e) {
      print("❌ addFood error: $e");
      return -1;
    }
  }

  @override
  Future<int> addStudentFoodRecord(int studentId, int foodId, DateTime date) async {
    try {
      final db = await database;
      return await db.insert('student_food', {
        'student_id': studentId,
        'food_id': foodId,
        'date': date.millisecondsSinceEpoch,
      });
    } catch (e) {
      print("❌ addStudentFoodRecord error: $e");
      return -1;
    }
  }

  @override
  Future<int> deleteRoom(int id) async {
    try {
      final db = await database;
      return await db.delete('room', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print("❌ deleteRoom error: $e");
      return -1;
    }
  }

  @override
  Future<int> deleteStudent(int id) async {
    try {
      final db = await database;
      return await db.delete('student', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print("❌ deleteStudent error: $e");
      return -1;
    }
  }

  @override
  Future<int> deleteFood(int id) async {
    try {
      final db = await database;
      return await db.delete('food', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print("❌ deleteFood error: $e");
      return -1;
    }
  }

  @override
  Future<int> deleteStudentFoodRecord(int recordId) async {
    try {
      final db = await database;
      return await db.delete('student_food', where: 'id = ?', whereArgs: [recordId]);
    } catch (e) {
      print("❌ deleteStudentFoodRecord error: $e");
      return -1;
    }
  }

  // ---------- Query Methods ----------

  @override
  Future<List<int>> getFoodIdsEatenByStudent(int studentId, DateTime date) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT food_id FROM student_food
        WHERE student_id = ? AND DATE(date / 1000, 'unixepoch') = DATE(? / 1000, 'unixepoch')
      ''', [studentId, date.millisecondsSinceEpoch]);

      return result.map((row) => row['food_id'] as int).toList();
    } catch (e) {
      print("❌ getFoodIdsEatenByStudent error: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentsWhoAteOnDate(DateTime date) async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT DISTINCT student.id, student.name
        FROM student_food
        JOIN student ON student.id = student_food.student_id
        WHERE DATE(student_food.date / 1000, 'unixepoch') = DATE(? / 1000, 'unixepoch')
      ''', [date.millisecondsSinceEpoch]);
    } catch (e) {
      print("❌ getStudentsWhoAteOnDate error: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentMealsOnDate(DateTime date) async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT student.id AS student_id, student.name, food.id AS food_id
        FROM student_food
        JOIN student ON student.id = student_food.student_id
        JOIN food ON food.id = student_food.food_id
        WHERE DATE(student_food.date / 1000, 'unixepoch') = DATE(? / 1000, 'unixepoch')
      ''', [date.millisecondsSinceEpoch]);
    } catch (e) {
      print("❌ getStudentMealsOnDate error: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllStudentsInRoom(int roomId) async {
    try {
      final db = await database;
      return await db.query('student', where: 'room_id = ?', whereArgs: [roomId]);
    } catch (e) {
      print("❌ getAllStudentsInRoom error: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      final db = await database;
      return await db.query('student');
    } catch (e) {
      print("❌ getAllStudents error: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllFood() async {
    try {
      final db = await database;
      return await db.query('food');
    } catch (e) {
      print("❌ getAllFood error: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllRooms() async {
    try {
      final db = await database;
      return await db.query('room');
    } catch (e) {
      print("❌ getAllRooms error: $e");
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentMealHistory(int studentId) async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT food.id AS food_id, food.name AS food_name, student_food.date
        FROM student_food
        JOIN food ON food.id = student_food.food_id
        WHERE student_food.student_id = ?
        ORDER BY student_food.date DESC
      ''', [studentId]);
    } catch (e) {
      print("❌ getStudentMealHistory error: $e");
      return [];
    }
  }
}
