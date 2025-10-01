// lib/features/home_page/pages/students_page/bloc/students_page_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostel_mess_2/core/domain/usecases/student_repo_usecase.dart';
import 'students_page_event.dart';
import 'students_page_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentOperationsUseCases studentUseCases;

  StudentBloc(this.studentUseCases) : super(const StudentInitial()) {
    on<LoadStudentsEvent>(_onLoadStudents);
    on<LoadRoomsEvent>(_onLoadRooms);
    on<AddStudentEvent>(_onAddStudent);
    on<DeleteStudentEvent>(_onDeleteStudent);
    on<DeleteSelectedStudentsEvent>(_onDeleteSelectedStudents);
    on<ToggleStudentSelectionEvent>(_onToggleStudentSelection);
    on<ToggleSelectionModeEvent>(_onToggleSelectionMode);
    on<SelectAllStudentsEvent>(_onSelectAllStudents);
    on<ClearSelectionEvent>(_onClearSelection);
    on<FilterByYearGroupEvent>(_onFilterByYearGroup);
    on<ClearFilterEvent>(_onClearFilter);
    on<ClearSuccessMessageEvent>(_onClearSuccessMessage);
  }

  Future<void> _onLoadStudents(LoadStudentsEvent event, Emitter<StudentState> emit) async {
    try {
      emit(const StudentLoading());
      
      final students = await studentUseCases.getAllStudents();
      final rooms = await studentUseCases.getAllRooms();
      
      // Generate year groups from student registration numbers
      final Map<String, int> yearGroups = {};
      for (final student in students) {
        String reg = student.reg;
        if (reg.length >= 8) {
          String year = reg.substring(5, 7); // 5th and 6th index (0-based)
          yearGroups[year] = (yearGroups[year] ?? 0) + 1;
        }
      }

      emit(StudentLoaded(
        students: students,
        rooms: rooms,
        yearGroups: yearGroups,
      ));
    } catch (e) {
      emit(StudentError('Failed to load students: ${e.toString()}'));
    }
  }

  Future<void> _onLoadRooms(LoadRoomsEvent event, Emitter<StudentState> emit) async {
    if (state is StudentLoaded) {
      try {
        final rooms = await studentUseCases.getAllRooms();
        final currentState = state as StudentLoaded;
        emit(currentState.copyWith(rooms: rooms));
      } catch (e) {
        emit(StudentError('Failed to load rooms: ${e.toString()}'));
      }
    }
  }
Future<void> _onAddStudent(AddStudentEvent event, Emitter<StudentState> emit) async {
  print('🔵 _onAddStudent started, current state: ${state.runtimeType}');
  
  if (state is StudentLoaded) {
    print('✅ State is StudentLoaded, proceeding...');
    final currentState = state as StudentLoaded;
    
    try {
      // Validate registration number
      if (event.reg.length != 10 || !RegExp(r'^\d{10}$').hasMatch(event.reg)) {
        print('❌ Validation failed: invalid registration number');
        // ✅ Keep the current state, just show error via snackbar
        emit(const StudentError('Registration number must be exactly 10 digits'));
        emit(currentState); // Re-emit current state to restore UI
        return;
      }

      // Validate name (only alphabets and spaces, convert to title case)
      String name = _toTitleCase(event.name);
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
        print('❌ Validation failed: invalid name');
        // ✅ Keep the current state, just show error via snackbar
        emit(const StudentError('Name should contain only alphabets and spaces'));
        emit(currentState); // Re-emit current state to restore UI
        return;
      }

      print('🔄 Adding student to database...');
      await studentUseCases.addStudent(name, event.reg, roomId: event.roomId);
      print('✅ Student added to database');
      
      // Reload students data
      print('🔄 Reloading students...');
      final students = await studentUseCases.getAllStudents();
      print('✅ Loaded ${students.length} students');
      
      final rooms = await studentUseCases.getAllRooms();
      print('✅ Loaded ${rooms.length} rooms');
      
      // Regenerate year groups
      final Map<String, int> yearGroups = {};
      for (final student in students) {
        String reg = student.reg;
        if (reg.length >= 8) {
          String year = reg.substring(5, 7);
          yearGroups[year] = (yearGroups[year] ?? 0) + 1;
        }
      }
      print('✅ Generated year groups: $yearGroups');
      
      // Emit success message
      print('🟢 Emitting StudentActionSuccess...');
      emit(const StudentActionSuccess('Student added successfully'));
      
      print('🟢 Emitting StudentLoaded with updated data...');
      emit(currentState.copyWith(
        students: students,
        rooms: rooms,
        yearGroups: yearGroups,
        selectedStudentIds: [],
      ));
      print('✅ _onAddStudent completed');
    } catch (e) {
      print('🔴 Error in _onAddStudent: $e');
      emit(StudentError('Failed to add student: ${e.toString()}'));
      emit(currentState); // Re-emit current state to restore UI
    }
  } else {
    print('❌ State is NOT StudentLoaded, it is: ${state.runtimeType}');
  }
}

  Future<void> _onDeleteStudent(DeleteStudentEvent event, Emitter<StudentState> emit) async {
    if (state is StudentLoaded) {
      try {
        await studentUseCases.deleteStudent(event.studentId);
        
        // Reload students data
        final students = await studentUseCases.getAllStudents();
        final rooms = await studentUseCases.getAllRooms();
        
        // Regenerate year groups
        final Map<String, int> yearGroups = {};
        for (final student in students) {
          String reg = student.reg;
          if (reg.length >= 8) {
            String year = reg.substring(5, 7); // 5th and 6th index (0-based)
            yearGroups[year] = (yearGroups[year] ?? 0) + 1;
          }
        }

        final currentState = state as StudentLoaded;
        
        
        // Emit success message after a brief delay
        emit(const StudentActionSuccess('Student deleted successfully'));
        await Future.delayed(const Duration(milliseconds: 100));
        emit(currentState.copyWith(
          students: students,
          rooms: rooms,
          yearGroups: yearGroups,
          selectedStudentIds: [], // Clear selection after deletion
        ));
      } catch (e) {
        emit(StudentError('Failed to delete student: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteSelectedStudents(DeleteSelectedStudentsEvent event, Emitter<StudentState> emit) async {
    if (state is StudentLoaded) {
      try {
        for (final studentId in event.studentIds) {
          await studentUseCases.deleteStudent(studentId);
        }
        
        // Reload students data
        final students = await studentUseCases.getAllStudents();
        final rooms = await studentUseCases.getAllRooms();
        
        // Regenerate year groups
        final Map<String, int> yearGroups = {};
        for (final student in students) {
          String reg = student.reg;
          if (reg.length >= 8) {
            String year = reg.substring(5, 7); // 5th and 6th index (0-based)
            yearGroups[year] = (yearGroups[year] ?? 0) + 1;
          }
        }

        final currentState = state as StudentLoaded;
        
        // Emit success message after a brief delay
        emit(StudentActionSuccess('${event.studentIds.length} students deleted successfully'));
        await Future.delayed(const Duration(milliseconds: 100));
        emit(currentState.copyWith(
          students: students,
          rooms: rooms,
          yearGroups: yearGroups,
          selectedStudentIds: [],
          isSelectionMode: false,
        ));
      } catch (e) {
        emit(StudentError('Failed to delete students: ${e.toString()}'));
      }
    }
  }

  void _onToggleStudentSelection(ToggleStudentSelectionEvent event, Emitter<StudentState> emit) {
    if (state is StudentLoaded) {
      final currentState = state as StudentLoaded;
      final selectedIds = List<int>.from(currentState.selectedStudentIds);
      
      if (selectedIds.contains(event.studentId)) {
        selectedIds.remove(event.studentId);
      } else {
        selectedIds.add(event.studentId);
      }

      emit(currentState.copyWith(
        selectedStudentIds: selectedIds,
        isSelectionMode: selectedIds.isNotEmpty,
      ));
    }
  }

  void _onToggleSelectionMode(ToggleSelectionModeEvent event, Emitter<StudentState> emit) {
    if (state is StudentLoaded) {
      final currentState = state as StudentLoaded;
      emit(currentState.copyWith(
        isSelectionMode: !currentState.isSelectionMode,
        selectedStudentIds: !currentState.isSelectionMode ? [] : currentState.selectedStudentIds,
      ));
    }
  }

  void _onSelectAllStudents(SelectAllStudentsEvent event, Emitter<StudentState> emit) {
    if (state is StudentLoaded) {
      final currentState = state as StudentLoaded;
      final allStudentIds = currentState.filteredStudents.map((s) => s.id).toList();
      
      // If all students are already selected, deselect all
      final allSelected = allStudentIds.every((id) => currentState.selectedStudentIds.contains(id));
      
      emit(currentState.copyWith(
        selectedStudentIds: allSelected ? [] : allStudentIds,
        isSelectionMode: !allSelected,
      ));
    }
  }

  void _onClearSelection(ClearSelectionEvent event, Emitter<StudentState> emit) {
    if (state is StudentLoaded) {
      final currentState = state as StudentLoaded;
      emit(currentState.copyWith(
        selectedStudentIds: [],
        isSelectionMode: false,
      ));
    }
  }

  void _onFilterByYearGroup(FilterByYearGroupEvent event, Emitter<StudentState> emit) {
    if (state is StudentLoaded) {
      final currentState = state as StudentLoaded;
      emit(currentState.copyWith(
        yearFilter: event.yearGroup,
        selectedStudentIds: [],
        isSelectionMode: false,
      ));
    }
  }

  void _onClearFilter(ClearFilterEvent event, Emitter<StudentState> emit) {
    if (state is StudentLoaded) {
      final currentState = state as StudentLoaded;
      emit(currentState.copyWith(
        clearYearFilter: true,
        selectedStudentIds: [],
        isSelectionMode: false,
      ));
    }
  }

  String _toTitleCase(String input) {
    return input.toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void _onClearSuccessMessage(ClearSuccessMessageEvent event, Emitter<StudentState> emit) {
    if (state is StudentLoaded) {
      final currentState = state as StudentLoaded;
      emit(currentState.copyWith(clearSuccessMessage: true));
    }
  }
}