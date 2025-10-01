class StudentEntity {
  final int id;
  final String name;
  final String reg;
  final int? roomId;
  
  StudentEntity({required this.id, required this.name, required this.reg, this.roomId});
}