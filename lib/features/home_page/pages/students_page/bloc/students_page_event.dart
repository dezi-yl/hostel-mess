// lib/features/home_page/pages/students_page/bloc/students_page_event.dart
import 'package:equatable/equatable.dart';

abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudentsEvent extends StudentEvent {
  const LoadStudentsEvent();
}

class LoadRoomsEvent extends StudentEvent {
  const LoadRoomsEvent();
}

class AddStudentEvent extends StudentEvent {
  final String name;
  final String reg;
  final int? roomId;

  const AddStudentEvent({
    required this.name,
    required this.reg,
    this.roomId,
  });

  @override
  List<Object?> get props => [name, reg, roomId];
}

class DeleteStudentEvent extends StudentEvent {
  final int studentId;

  const DeleteStudentEvent(this.studentId);

  @override
  List<Object> get props => [studentId];
}

class DeleteSelectedStudentsEvent extends StudentEvent {
  final List<int> studentIds;

  const DeleteSelectedStudentsEvent(this.studentIds);

  @override
  List<Object> get props => [studentIds];
}

class ToggleStudentSelectionEvent extends StudentEvent {
  final int studentId;

  const ToggleStudentSelectionEvent(this.studentId);

  @override
  List<Object> get props => [studentId];
}

class ToggleSelectionModeEvent extends StudentEvent {
  const ToggleSelectionModeEvent();
}

class SelectAllStudentsEvent extends StudentEvent {
  const SelectAllStudentsEvent();
}

class ClearSelectionEvent extends StudentEvent {
  const ClearSelectionEvent();
}

class FilterByYearGroupEvent extends StudentEvent {
  final String yearGroup;

  const FilterByYearGroupEvent(this.yearGroup);

  @override
  List<Object> get props => [yearGroup];
}

class ClearFilterEvent extends StudentEvent {
  const ClearFilterEvent();
}

class ClearSuccessMessageEvent extends StudentEvent {
  const ClearSuccessMessageEvent();
}