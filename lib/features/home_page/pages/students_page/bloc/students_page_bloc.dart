import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hostel_mess_2/core/domain/entities/room_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/student_entity.dart';
import 'package:hostel_mess_2/core/domain/usecases/student_repo_usecase.dart';

part 'students_page_event.dart';
part 'students_page_state.dart';
// student_bloc.dart
class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentOperationsUseCases useCases;

  StudentBloc(this.useCases) : super(StudentInitial()) {
    on<LoadStudentsEvent>(_onLoadStudents);
    on<AddStudentEvent>(_onAddStudent);
  }

  Future<void> _onLoadStudents(
      LoadStudentsEvent event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      final rooms = await useCases.getAllRooms();
      final students = event.roomId != null
          ? await useCases.getAllStudentsInRoom(event.roomId!)
          : await useCases.getAllStudents();
      emit(StudentLoaded(
        students: students,
        rooms: rooms,
        selectedRoomId: event.roomId,
      ));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onAddStudent(
      AddStudentEvent event, Emitter<StudentState> emit) async {
    if (state is StudentLoaded) {
      try {
        await useCases.addStudent(event.name, event.reg, roomId: event.roomId);
        add(LoadStudentsEvent(roomId: (state as StudentLoaded).selectedRoomId));
      } catch (e) {
        emit(StudentError(e.toString()));
      }
    }
  }
}
