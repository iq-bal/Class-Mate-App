import 'package:flutter/material.dart';

class ParticipantSelectorModal extends StatefulWidget {
  final List<Map<String, String>> allUsers;
  final List<Map<String, String>> selectedParticipants;
  final ValueChanged<Map<String, String>> onParticipantSelected;
  final ValueChanged<Map<String, String>> onParticipantRemoved;

  const ParticipantSelectorModal({
    super.key,
    required this.allUsers,
    required this.selectedParticipants,
    required this.onParticipantSelected,
    required this.onParticipantRemoved,
  });

  @override
  State<ParticipantSelectorModal> createState() =>
      _ParticipantSelectorModalState();
}

class _ParticipantSelectorModalState extends State<ParticipantSelectorModal> {
  late List<Map<String, String>> filteredUsers;

  @override
  void initState() {
    super.initState();
    filteredUsers = List.from(widget.allUsers);
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = List.from(widget.allUsers);
      } else {
        filteredUsers = widget.allUsers
            .where((user) =>
            user["name"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 80.0),
          child: Column(
            children: [
              // Header with Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Participants",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check, color: Colors.teal),
                  ),
                ],
              ),
              const Divider(),

              // Search Field
              TextField(
                onChanged: _filterUsers,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  hintText: "Search participants",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Participant List
              Expanded(
                child: filteredUsers.isNotEmpty
                    ? ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isSelected = widget.selectedParticipants
                        .any((participant) =>
                    participant["name"] == user["name"]);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(user["avatar"]!),
                      ),
                      title: Text(user["name"]!),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.teal)
                          : null,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            widget.onParticipantRemoved(user);
                          } else {
                            widget.onParticipantSelected(user);
                          }
                        });
                      },
                    );
                  },
                )
                    : const Center(
                  child: Text(
                    "No participants found",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
