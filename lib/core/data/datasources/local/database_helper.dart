abstract class LocalDatabaseHelper {
  // ✅ Data Manipulation Methods  
  // ───────────────────────────────
  // Add operations  
  Future<int> addRoom(String name);
  Future<int> addStudent(String name, String reg, int? roomId);
  Future<int> addFood(String name);
  Future<int> addStudentFoodRecord(int studentId, int foodId, DateTime date);
  
  // Delete operations  
  Future<int> deleteRoom(int id);
  Future<int> deleteStudent(int id);
  Future<int> deleteFood(int id);
  Future<int> deleteStudentFoodRecord(int recordId);

  // ✅ Queries  
  // ───────────────────────────────
  
  /// Get **List of IDs of foods** eaten by a student on a specific date
  Future<List<int>> getFoodIdsEatenByStudent(int studentId, DateTime date);

  /// Get **list of students** who ate on a specific date  
  Future<List<Map<String, dynamic>>> getStudentsWhoAteOnDate(DateTime date);

  /// Get **students and their food IDs** on a specific date  
  Future<List<Map<String, dynamic>>> getStudentMealsOnDate(DateTime date);

  /// Get **all students assigned to a specific room**  
  Future<List<Map<String, dynamic>>> getAllStudentsInRoom(int roomId);

  /// Get **all students**  
  Future<List<Map<String, dynamic>>> getAllStudents();

  /// Get **all food items**  
  Future<List<Map<String, dynamic>>> getAllFood();

  /// Get **all rooms**  
  Future<List<Map<String, dynamic>>> getAllRooms();

  /// Get a student’s full meal history  
  Future<List<Map<String, dynamic>>> getStudentMealHistory(int studentId);

}
