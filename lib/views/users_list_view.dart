import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class UsersListView extends StatefulWidget {
  final String currentUserEmail;
  final VoidCallback? onFollowChanged;
  const UsersListView({Key? key, required this.currentUserEmail, this.onFollowChanged}) : super(key: key);

  @override
  State<UsersListView> createState() => _UsersListViewState();
}

class _UsersListViewState extends State<UsersListView> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await AuthService().searchUsers('');
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: $e')),
      );
    }
  }

  Future<void> _toggleFollow(User user) async {
    final _currentUserEmail = widget.currentUserEmail;
    if (_currentUserEmail == user.email) return;
    final authService = AuthService();
    final isFollowing = user.followers.contains(_currentUserEmail);
    bool success;
    setState(() {
      // Optimistically update the UI
      if (isFollowing) {
        user.followers.remove(_currentUserEmail);
      } else {
        user.followers.add(_currentUserEmail);
      }
    });
    if (isFollowing) {
      success = await authService.unfollowUser(_currentUserEmail, user.email);
    } else {
      success = await authService.followUser(_currentUserEmail, user.email);
    }
    if (!success) {
      // Revert if failed
      setState(() {
        if (isFollowing) {
          user.followers.add(_currentUserEmail);
        } else {
          user.followers.remove(_currentUserEmail);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating follow status')),
      );
    } else {
      // Always re-fetch users from DB to ensure state is correct
      await _fetchUsers();
      if (widget.onFollowChanged != null) widget.onFollowChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        backgroundColor: const Color(0xFF232946),
      ),
      backgroundColor: const Color(0xFF121212),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('No hay usuarios', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final isMe = user.email == widget.currentUserEmail;
                    final isFollowing = user.followers.contains(widget.currentUserEmail);
                    return Card(
                      color: const Color(0xFF232946),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        trailing: isMe
                            ? null
                            : ElevatedButton(
                                onPressed: () => _toggleFollow(user),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFollowing ? Colors.grey : Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
} 