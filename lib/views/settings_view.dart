import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_provider.dart';
import '../viewmodels/language_provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../viewmodels/favorites_provider.dart';
import 'home_view.dart';

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
  bool _showAllFavorites = false;

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

  bool _hoveringCard = false;
  bool _hoveringEdit = false;

  Widget _userCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? Colors.black.withOpacity(0.65)
        : Colors.white.withOpacity(0.85);
    final borderColor = isDark ? Colors.blue[900] : Colors.blue[200];
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveringCard = true),
      onExit: (_) => setState(() => _hoveringCard = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor!, width: 2),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.blue.withOpacity(_hoveringCard ? 0.25 : 0.15)
                  : Colors.blue.withOpacity(_hoveringCard ? 0.18 : 0.10),
              blurRadius: _hoveringCard ? 24 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditableRow(
                icon: Icons.person,
                label: 'Name',
                value: _user?.name ?? '',
                editing: _editingField == 'name',
                controller: _nameController,
                onEdit: () => setState(() => _editingField = 'name'),
                onCancel: () => setState(() => _editingField = null),
                onSave: _saveProfile,
                saving: _saving,
                error: _editingField == 'name' ? _error : null,
                isDark: isDark,
              ),
              const SizedBox(height: 18),
              _buildEditableRow(
                icon: Icons.email,
                label: 'Email',
                value: _user?.email ?? '',
                editing: _editingField == 'email',
                controller: _emailController,
                onEdit: () => setState(() => _editingField = 'email'),
                onCancel: () => setState(() => _editingField = null),
                onSave: _saveProfile,
                saving: _saving,
                error: _editingField == 'email' ? _error : null,
                isDark: isDark,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              _buildBirthDateRow(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableRow({
    required IconData icon,
    required String label,
    required String value,
    required bool editing,
    required TextEditingController controller,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required VoidCallback onSave,
    required bool saving,
    String? error,
    bool isDark = false,
    TextInputType? keyboardType,
  }) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: editing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      keyboardType: keyboardType,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: label,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(error, style: const TextStyle(color: Colors.red)),
                      ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: saving ? null : onSave,
                          icon: saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: Text(l10n.save),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: onCancel,
                          icon: const Icon(Icons.cancel),
                          label: Text(l10n.cancel),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            value,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                      tooltip: l10n.edit,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildBirthDateRow(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.cake, color: Colors.blue, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: _editingField == 'birthDate'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _pickBirthDate,
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Birth Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_birthDate == null
                            ? 'Select birth date'
                            : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'),
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
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
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: _saving ? null : () => setState(() => _editingField = null),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                )
              : Text(
                  _user?.birthDate != null
                      ? '${_user!.birthDate.year}-${_user!.birthDate.month.toString().padLeft(2, '0')}-${_user!.birthDate.day.toString().padLeft(2, '0')}'
                      : '',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
        MouseRegion(
          onEnter: (_) => setState(() => _hoveringEdit = true),
          onExit: (_) => setState(() => _hoveringEdit = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _hoveringEdit ? Colors.blue.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => setState(() => _editingField = 'birthDate'),
              tooltip: 'Edit Birth Date',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesSection(bool isDark) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final l10n = AppLocalizations.of(context);
    final List<int> favorites = favoritesProvider.favoriteNewsIndexes;
    if (favorites.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withOpacity(0.65) : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? Colors.blue[900]! : Colors.blue[200]!, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Icon(Icons.bookmark, color: Colors.amber[700], size: 28),
              const SizedBox(width: 12),
              Text(
                'No hay favoritos guardados',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final showAll = _showAllFavorites || favorites.length <= 3;
    final displayedFavorites = showAll ? favorites : favorites.take(3).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.65) : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.blue[900]! : Colors.blue[200]!, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bookmark, color: Colors.amber[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  'Favoritos / Guardados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...displayedFavorites.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomeView(
                        user: widget.user!,
                        initialNewsIndex: i,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blueGrey[900] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.book, size: 18, color: Colors.amber[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).getNewsHeadline(i + 1),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Text(
                          AppLocalizations.of(context).getNewsSummary(i + 1),
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
            if (favorites.length > 3 && !_showAllFavorites)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllFavorites = true;
                    });
                  },
                  child: const Text('Ver más'),
                ),
              ),
            if (favorites.length > 3 && _showAllFavorites)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllFavorites = false;
                    });
                  },
                  child: const Text('Ver menos'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(bool isDark) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLocale = languageProvider.currentLocale.languageCode;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.65) : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.blue[900]! : Colors.blue[200]!, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Text(
                  l10n.language,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLanguageOption(
                  'es',
                  'Español',
                  '🇪🇸',
                  currentLocale == 'es',
                  isDark,
                  () => languageProvider.setLocale('es'),
                ),
                _buildLanguageOption(
                  'ca',
                  'Català',
                  '🏴󠁥󠁳󠁣󠁴󠁿',
                  currentLocale == 'ca',
                  isDark,
                  () => languageProvider.setLocale('ca'),
                ),
                _buildLanguageOption(
                  'en',
                  'English',
                  '🇬🇧',
                  currentLocale == 'en',
                  isDark,
                  () => languageProvider.setLocale('en'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    String code,
    String name,
    String flag,
    bool isSelected,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.blue[900] : Colors.blue[100])
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.blue[700]! : Colors.blue[300]!)
                : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _userCard(),
            _buildFavoritesSection(isDark),
            _buildLanguageSection(isDark),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(l10n.theme),
              trailing: Switch(
                value: isDark,
                onChanged: (value) {
                  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                  themeProvider.toggleTheme(value);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.logout),
              onTap: () async {
                final authService = AuthService();
                await authService.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
} 