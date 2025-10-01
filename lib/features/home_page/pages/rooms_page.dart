import 'package:flutter/material.dart';
import 'package:hostel_mess_2/core/di/dependency_injection.dart';
import 'package:hostel_mess_2/core/domain/entities/room_entity.dart';
import 'package:hostel_mess_2/core/domain/usecases/student_repo_usecase.dart';
import 'package:hostel_mess_2/features/home_page/pages/room_details_page.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final StudentOperationsUseCases useCases = locator<StudentOperationsUseCases>();
  late Future<List<RoomEntity>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _roomsFuture = useCases.getAllRooms();
  }

  Future<void> _showAddRoomDialog() async {
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Room"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Room Name"),
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

    if (result == true && nameController.text.isNotEmpty) {
      await useCases.addRoom(nameController.text);
      setState(() {
        _roomsFuture = useCases.getAllRooms();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rooms")),
      body: FutureBuilder<List<RoomEntity>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No rooms found"));
          }

          final rooms = snapshot.data!;
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return FutureBuilder(
                future: useCases.getAllStudentsInRoom(room.id),
                builder: (context, studentSnapshot) {
                  int count = 0;
                  if (studentSnapshot.hasData) {
                    count = studentSnapshot.data!.length;
                  }

                  return ListTile(
                    leading: const Icon(Icons.meeting_room),
                    title: Text(room.name),
                    subtitle: Text("Students: $count"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoomDetailsPage(room: room),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
