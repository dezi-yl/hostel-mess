// lib/features/home_page/pages/students_page/students_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostel_mess_2/core/domain/entities/student_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/room_entity.dart';
import 'bloc/students_page_bloc.dart';
import 'bloc/students_page_event.dart';
import 'bloc/students_page_state.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          final state = context.read<StudentBloc>().state;
          if (state is StudentLoaded && state.isSelectionMode) {
            context.read<StudentBloc>().add(const ClearSelectionEvent());
          } else {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Students',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.grey[200],
            ),
          ),
        ),
        body: BlocConsumer<StudentBloc, StudentState>(
          listener: (context, state) {
            print('🎯 UI Listener received state: ${state.runtimeType}');

            if (state is StudentError) {
              print('🔴 Showing error snackbar: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is StudentActionSuccess) {
              print('🟢 Showing action success snackbar: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is StudentLoaded && state.successMessage != null) {
              print('🟢 Showing loaded success snackbar: ${state.successMessage}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is StudentLoaded) {
              print('📊 StudentLoaded state: ${state.students.length} students, successMessage: ${state.successMessage}');
            }
          },
          builder: (context, state) {
            if (state is StudentLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            }

            if (state is StudentLoaded) {
              return Column(
                children: [
                  // Year Groups Section
                  if (state.yearGroups.isNotEmpty) _buildYearGroupsSection(context, state),

                  // Students List Header
                  _buildStudentsHeader(context, state),

                  // Students List
                  Expanded(
                    child: state.filteredStudents.isEmpty ? _buildEmptyState(context) : _buildStudentsList(context, state),
                  ),
                ],
              );
            }

            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
        floatingActionButton: BlocBuilder<StudentBloc, StudentState>(
          builder: (context, state) {
            if (state is StudentLoaded && state.isSelectionMode) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (state.selectedStudentIds.isNotEmpty) ...[
                    FloatingActionButton.extended(
                      onPressed: () => _showDeleteConfirmation(context, state.selectedStudentIds),
                      backgroundColor: Colors.red,
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: Text(
                        'Delete (${state.selectedStudentIds.length})',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  FloatingActionButton(
                    onPressed: () {
                      context.read<StudentBloc>().add(const ClearSelectionEvent());
                    },
                    backgroundColor: Colors.grey[600],
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              );
            }

            if (state is StudentLoaded) {
              return FloatingActionButton(
                onPressed: () => _showAddStudentDialog(context, state),
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add, color: Colors.white),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildYearGroupsSection(BuildContext context, StudentLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Year Groups',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // Fixed height container to prevent shifting
              SizedBox(
                height: 32,
                child: state.yearFilter != null
                    ? TextButton(
                        onPressed: () {
                          context.read<StudentBloc>().add(const ClearFilterEvent());
                        },
                        child: const Text(
                          'Show All',
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.yearGroups.length,
              itemBuilder: (context, index) {
                final year = state.yearGroups.keys.toList()[index];
                final count = state.yearGroups[year]!;
                final isSelected = state.yearFilter == year;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text('Year $year ($count)'),
                    onSelected: (selected) {
                      if (isSelected) {
                        context.read<StudentBloc>().add(const ClearFilterEvent());
                      } else {
                        context.read<StudentBloc>().add(FilterByYearGroupEvent(year));
                      }
                    },
                    selectedColor: Colors.blue.withOpacity(0.2),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsHeader(BuildContext context, StudentLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Text(
            state.yearFilter != null
                ? 'Year ${state.yearFilter} Students (${state.filteredStudents.length})'
                : 'All Students (${state.students.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          if (state.isSelectionMode) ...[
            Builder(
              builder: (context) {
                final allStudentIds = state.filteredStudents.map((s) => s.id).toList();
                final allSelected = allStudentIds.every((id) => state.selectedStudentIds.contains(id));

                return TextButton(
                  onPressed: () {
                    context.read<StudentBloc>().add(const SelectAllStudentsEvent());
                  },
                  child: Text(
                    allSelected ? 'Deselect All' : 'Select All',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No students found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first student to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(BuildContext context, StudentLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.filteredStudents.length,
      itemBuilder: (context, index) {
        final student = state.filteredStudents[index];
        final room = state.rooms.firstWhere(
          (r) => r.id == student.roomId,
          orElse: () => RoomEntity(id: 0, name: 'No Room'),
        );
        final isSelected = state.selectedStudentIds.contains(student.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[200]!,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: state.isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      context.read<StudentBloc>().add(
                            ToggleStudentSelectionEvent(student.id),
                          );
                    },
                  )
                : CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Text(
                      student.name.split(' ').map((n) => n[0]).take(2).join(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
            title: Text(
              student.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reg: ${student.reg}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                if (student.roomId != null)
                  Text(
                    'Room: ${room.name}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            onTap: state.isSelectionMode
                ? () {
                    context.read<StudentBloc>().add(
                          ToggleStudentSelectionEvent(student.id),
                        );
                  }
                : null,
            onLongPress: () {
              if (!state.isSelectionMode) {
                context.read<StudentBloc>().add(const ToggleSelectionModeEvent());
                context.read<StudentBloc>().add(
                      ToggleStudentSelectionEvent(student.id),
                    );
              }
            },
          ),
        );
      },
    );
  }

  void _showAddStudentDialog(BuildContext context, StudentLoaded state) {
    final nameController = TextEditingController();
    final regController = TextEditingController();
    final roomSearchController = TextEditingController();
    RoomEntity? selectedRoom;
    List<RoomEntity> filteredRooms = state.rooms;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Add New Student',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter student name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: regController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Number',
                    hintText: '1521823001',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    _showRoomSelectionDialog(
                      dialogContext,
                      state.rooms,
                      selectedRoom,
                      (room) {
                        setState(() => selectedRoom = room);
                      },
                    );
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Room (Optional)',
                        hintText: 'Select a room',
                        border: const OutlineInputBorder(),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selectedRoom != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() => selectedRoom = null);
                                },
                              ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                      controller: TextEditingController(
                        text: selectedRoom?.name ?? '',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final reg = regController.text.trim();

                if (name.isNotEmpty && reg.isNotEmpty) {
                  context.read<StudentBloc>().add(
                        AddStudentEvent(
                          name: name,
                          reg: reg,
                          roomId: selectedRoom?.id,
                        ),
                      );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Add Student'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomSelectionDialog(
    BuildContext context,
    List<RoomEntity> allRooms,
    RoomEntity? currentRoom,
    Function(RoomEntity?) onRoomSelected,
  ) {
    final searchController = TextEditingController();
    List<RoomEntity> filteredRooms = allRooms;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Select Room',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search rooms...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        filteredRooms = allRooms;
                      } else {
                        filteredRooms = allRooms
                            .where((room) => room.name.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: filteredRooms.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No rooms found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredRooms.length,
                          itemBuilder: (context, index) {
                            final room = filteredRooms[index];
                            final isSelected = currentRoom?.id == room.id;

                            return ListTile(
                              title: Text(room.name),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: Colors.blue)
                                  : null,
                              selected: isSelected,
                              selectedTileColor: Colors.blue.withOpacity(0.1),
                              onTap: () {
                                onRoomSelected(room);
                                Navigator.of(dialogContext).pop();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                onRoomSelected(null);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Clear Selection'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, List<int> studentIds) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Students'),
        content: Text(
          studentIds.length == 1
              ? 'Are you sure you want to delete this student?'
              : 'Are you sure you want to delete ${studentIds.length} students?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (studentIds.length == 1) {
                context.read<StudentBloc>().add(DeleteStudentEvent(studentIds.first));
              } else {
                context.read<StudentBloc>().add(DeleteSelectedStudentsEvent(studentIds));
              }
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}