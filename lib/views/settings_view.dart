import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class SettingsView extends StatefulWidget {
  final User? user;
  const SettingsView({super.key, this.user});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  DateTime? _birthDate;
  User? _user;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  final AuthService _authService = AuthService();
  String? _editingField; // 'name', 'email', 'birthDate'

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() => _loading = true);
    final email = widget.user?.email;
    if (email != null) {
      final user = widget.user;
      setState(() {
        _user = user;
        _nameController = TextEditingController(text: user?.name ?? '');
        _emailController = TextEditingController(text: user?.email ?? '');
        _birthDate = user?.birthDate;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  bool _validateFields() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (_editingField == 'name' && name.isEmpty) {
      setState(() => _error = 'Name cannot be empty');
      return false;
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (_editingField == 'email' && !emailRegex.hasMatch(email)) {
      setState(() => _error = 'Invalid email format');
      return false;
    }
    if (_editingField == 'birthDate' && _birthDate == null) {
      setState(() => _error = 'Birth date is required');
      return false;
    }
    if (_editingField == 'birthDate') {
      final minDate = DateTime.now().subtract(const Duration(days: 365 * 13));
      if (_birthDate!.isAfter(minDate)) {
        setState(() => _error = 'You must be at least 13 years old');
        return false;
      }
    }
    setState(() => _error = null);
    return true;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    if (!_validateFields()) return;
    setState(() => _saving = true);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final success = await _authService.updateUser(
      _user!.email,
      name: _editingField == 'name' ? name : null,
      newEmail: _editingField == 'email' ? email : null,
      birthDate: _editingField == 'birthDate' ? _birthDate : null,
    );
    setState(() => _saving = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
      setState(() {
        _user = User(
          email: _editingField == 'email' ? email : _user!.email,
          password: _user!.password,
          name: _editingField == 'name' ? name : _user!.name,
          birthDate: _editingField == 'birthDate' ? _birthDate! : _user!.birthDate,
          acceptedTerms: _user!.acceptedTerms,
        );
        _editingField = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _userCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: _editingField == 'name'
                      ? TextField(
                          controller: _nameController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        )
                      : Text(
                          _user?.name ?? '',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => setState(() => _editingField = 'name'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.email, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: _editingField == 'email'
                      ? TextField(
                          controller: _emailController,
                          autofocus: true,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        )
                      : Text(
                          _user?.email ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => setState(() => _editingField = 'email'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.cake, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: _editingField == 'birthDate'
                      ? InkWell(
                          onTap: _pickBirthDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Birth Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_birthDate == null
                                ? 'Select birth date'
                                : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'),
                          ),
                        )
                      : Text(
                          _user?.birthDate != null
                              ? '${_user!.birthDate.year}-${_user!.birthDate.month.toString().padLeft(2, '0')}-${_user!.birthDate.day.toString().padLeft(2, '0')}'
                              : '',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => setState(() => _editingField = 'birthDate'),
                ),
              ],
            ),
            if (_editingField != null) ...[
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _saveProfile,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _saving ? null : () => setState(() => _editingField = null),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/background_sky.png',
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.25), // overlay for readability
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _userCard(),
                    ListTile(
                      leading: const Icon(Icons.brightness_6),
                      title: const Text('Dark Mode'),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (value) {
                          themeProvider.toggleTheme(value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
} 