part of 'students_page_bloc.dart';

// student_event.dart
abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudentsEvent extends StudentEvent {
  final int? roomId; // null = all students
  const LoadStudentsEvent({this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class AddStudentEvent extends StudentEvent {
  final String name;
  final String reg;
  final int? roomId;
  const AddStudentEvent(this.name, this.reg, {this.roomId});

  @override
  List<Object?> get props => [name, reg, roomId];
}
