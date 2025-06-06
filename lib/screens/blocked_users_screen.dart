import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class BlockedUsersScreen extends StatefulWidget {
  final String currentUserEmail;
  final DatabaseService databaseService;

  const BlockedUsersScreen({
    Key? key,
    required this.currentUserEmail,
    required this.databaseService,
  }) : super(key: key);

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<String> blockedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadBlockedUsers();
  }

  Future<void> _initializeAndLoadBlockedUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Initialize database connection
      await widget.databaseService.connect();
      
      // Load blocked users
      final users = await widget.databaseService.getBlockedUsers(widget.currentUserEmail);
      setState(() {
        blockedUsers = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading blocked users: $e')),
      );
    }
  }

  Future<void> _unblockUser(String userEmail) async {
    try {
      final success = await widget.databaseService.unblockUser(
        widget.currentUserEmail,
        userEmail,
      );

      if (success) {
        setState(() {
          blockedUsers.remove(userEmail);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User unblocked successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to unblock user')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error unblocking user: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Disconnect from database when screen is disposed
    widget.databaseService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : blockedUsers.isEmpty
              ? const Center(
                  child: Text(
                    'No blocked users',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: blockedUsers.length,
                  itemBuilder: (context, index) {
                    final userEmail = blockedUsers[index];
                    return ListTile(
                      title: Text(userEmail),
                      trailing: IconButton(
                        icon: const Icon(Icons.block),
                        onPressed: () => _unblockUser(userEmail),
                      ),
                    );
                  },
                ),
    );
  }
} 