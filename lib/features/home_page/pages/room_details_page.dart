import 'package:flutter/material.dart';
import 'package:hostel_mess_2/core/di/dependency_injection.dart';
import 'package:hostel_mess_2/core/domain/entities/room_entity.dart';
import 'package:hostel_mess_2/core/domain/entities/student_entity.dart';
import 'package:hostel_mess_2/core/domain/usecases/student_repo_usecase.dart';

class RoomDetailsPage extends StatefulWidget {
  final RoomEntity room;

  const RoomDetailsPage({super.key, required this.room});

  @override
  State<RoomDetailsPage> createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends State<RoomDetailsPage> {
  final StudentOperationsUseCases useCases = locator<StudentOperationsUseCases>();
  late Future<List<StudentEntity>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = useCases.getAllStudentsInRoom(widget.room.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Room: ${widget.room.name}")),
      body: FutureBuilder<List<StudentEntity>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No students in this room"));
          }

          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                leading: CircleAvatar(child: Text(student.name[0])),
                title: Text(student.name),
                subtitle: Text("Reg: ${student.reg}"),
              );
            },
          );
        },
      ),
    );
  }
}
