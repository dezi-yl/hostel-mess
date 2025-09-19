import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostel_mess_2/core/di/dependency_injection.dart';
import 'package:hostel_mess_2/core/domain/entities/room_entity.dart';
import 'package:hostel_mess_2/features/home_page/pages/students_page/bloc/students_page_bloc.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StudentBloc(locator())..add(const LoadStudentsEvent()), // initial load
      child: const _StudentsView(),
    );
  }
}

class _StudentsView extends StatelessWidget {
  const _StudentsView();

  Future<void> _showAddStudentDialog(BuildContext context, List<RoomEntity> rooms) async {
    final nameController = TextEditingController();
    final regController = TextEditingController();
    int? selectedRoomId;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Student"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: regController,
                decoration: const InputDecoration(labelText: "Reg No"),
              ),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Assign Room"),
                value: selectedRoomId,
                items: rooms
                    .map((room) => DropdownMenuItem(
                          value: room.id,
                          child: Text(room.name),
                        ))
                    .toList(),
                onChanged: (value) => selectedRoomId = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );

    if (result == true &&
        nameController.text.isNotEmpty &&
        regController.text.isNotEmpty) {
      context.read<StudentBloc>().add(
            AddStudentEvent(
              nameController.text,
              regController.text,
              roomId: selectedRoomId,
            ),
          );
    }
  }

  void _showFilterSheet(BuildContext context, List<RoomEntity> rooms) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text("Show All"),
              onTap: () {
                Navigator.pop(context);
                context.read<StudentBloc>().add(const LoadStudentsEvent());
              },
            ),
            ...rooms.map((room) => ListTile(
                  leading: const Icon(Icons.meeting_room),
                  title: Text("Room: ${room.name}"),
                  onTap: () {
                    Navigator.pop(context);
                    context
                        .read<StudentBloc>()
                        .add(LoadStudentsEvent(roomId: room.id));
                  },
                )),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students"),
        actions: [
          BlocBuilder<StudentBloc, StudentState>(
            builder: (context, state) {
              if (state is StudentLoaded) {
                return IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterSheet(context, state.rooms),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is StudentLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StudentError) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is StudentLoaded) {
            if (state.students.isEmpty) {
              return const Center(child: Text("No students found"));
            }
            return ListView.builder(
              itemCount: state.students.length,
              itemBuilder: (context, index) {
                final student = state.students[index];
                final roomName = state.rooms
                    .firstWhere(
                      (r) => r.id == student.roomId,
                      orElse: () => RoomEntity(id: -1, name: "No Room"),
                    )
                    .name;

                return ListTile(
                  leading: CircleAvatar(child: Text(student.name[0])),
                  title: Text(student.name),
                  subtitle: Text("Reg: ${student.reg} • Room: $roomName"),
                );
              },
            );
          }
          return const Center(child: Text("Initializing..."));
        },
      ),
      floatingActionButton: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is StudentLoaded) {
            return FloatingActionButton(
              onPressed: () => _showAddStudentDialog(context, state.rooms),
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}