part of 'students_page_bloc.dart';

// student_state.dartore/domain/entities/room_entity.dart';

abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<StudentEntity> students;
  final List<RoomEntity> rooms;
  final int? selectedRoomId;

  const StudentLoaded({
    required this.students,
    required this.rooms,
    this.selectedRoomId,
  });

  @override
  List<Object?> get props => [students, rooms, selectedRoomId];
}

class StudentError extends StudentState {
  final String message;
  const StudentError(this.message);

  @override
  List<Object?> get props => [message];
}
