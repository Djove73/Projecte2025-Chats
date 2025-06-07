import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_provider.dart';
import '../viewmodels/language_provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';
import '../viewmodels/favorites_provider.dart';
import '../screens/blocked_users_screen.dart';
import 'home_view.dart';
import 'package:intl/intl.dart';
import '../viewmodels/login_viewmodel.dart';
import 'login_view.dart';

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
  final DatabaseService _databaseService = DatabaseService();
  String? _editingField; // 'name', 'email', 'birthDate'
  bool _showAllFavorites = false;

  @override
  void initState() {
    super.initState();
    _initializeAndFetchUser();
  }

  Future<void> _initializeAndFetchUser() async {
    setState(() => _loading = true);
    try {
      // Initialize database connection
      await _databaseService.connect();
      
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
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing: $e')),
      );
    }
  }

  bool _validateFields() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    
    // Clear previous error
    setState(() => _error = null);
    
    // Validate based on the field being edited
    switch (_editingField) {
      case 'name':
        if (name.isEmpty) {
          setState(() => _error = 'El nombre no puede estar vacío');
          return false;
        }
        break;
      case 'email':
        if (email.isEmpty) {
          setState(() => _error = 'El email no puede estar vacío');
          return false;
        }
        if (!email.contains('@') || !email.contains('.')) {
          setState(() => _error = 'Formato de email inválido');
          return false;
        }
        break;
      case 'birthDate':
        if (_birthDate == null) {
          setState(() => _error = 'La fecha de nacimiento es requerida');
          return false;
        }
        final minDate = DateTime.now().subtract(const Duration(days: 365 * 13));
        if (_birthDate!.isAfter(minDate)) {
          setState(() => _error = 'Debes tener al menos 13 años');
          return false;
        }
        break;
    }
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
    
    try {
      if (!_validateFields()) return;
      
      setState(() => _saving = true);
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final currentEditingField = _editingField; // Guardamos el campo que se está editando
      
      final success = await _authService.updateUser(
        _user!.email,
        name: currentEditingField == 'name' ? name : null,
        newEmail: currentEditingField == 'email' ? email : null,
        birthDate: currentEditingField == 'birthDate' ? _birthDate : null,
      );
      
      if (success) {
        // Update local user data
        setState(() {
          _user = User(
            email: currentEditingField == 'email' ? email : _user!.email,
            password: _user!.password,
            name: currentEditingField == 'name' ? name : _user!.name,
            birthDate: currentEditingField == 'birthDate' ? _birthDate! : _user!.birthDate,
            acceptedTerms: _user!.acceptedTerms,
          );
          _editingField = null;
        });
        
        // Show success message
        String message = 'Datos actualizados: ';
        if (currentEditingField == 'name') {
          message += 'Nombre cambiado a $name';
        } else if (currentEditingField == 'email') {
          message += 'Email cambiado a $email';
        } else if (currentEditingField == 'birthDate') {
          message += 'Fecha de nacimiento cambiada a ${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudieron actualizar los datos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _databaseService.disconnect();
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                          label: const Text('Save'),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: _saving ? null : onCancel,
                          child: const Text('Cancel'),
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
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de Nacimiento',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _birthDate != null
                              ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
                              : 'Seleccionar fecha',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    if (_error != null && _editingField == 'birthDate')
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saving ? null : _saveProfile,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: const Text('Guardar'),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: _saving ? null : () => setState(() => _editingField = null),
                          child: const Text('Cancelar'),
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
                            'Fecha de Nacimiento',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _user?.birthDate != null
                                ? '${_user!.birthDate.year}-${_user!.birthDate.month.toString().padLeft(2, '0')}-${_user!.birthDate.day.toString().padLeft(2, '0')}'
                                : '',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                          tooltip: 'Editar Fecha de Nacimiento',
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildFavoritesSection(bool isDark) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final l10n = AppLocalizations.of(context);
    final favorites = favoritesProvider.favorites;
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
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.65) : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.blue[900]! : Colors.blue[200]!, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bookmark, color: Colors.amber[700], size: 24),
                const SizedBox(width: 10),
                Text(
                  'Favoritos / Guardados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...displayedFavorites.map((fav) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomeView(
                        user: widget.user!,
                        initialNewsIndex: fav.index,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blueGrey[900] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Row(
                    children: [
                      Icon(Icons.book, size: 16, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).getNewsHeadline(fav.index + 1),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              AppLocalizations.of(context).getNewsSummary(fav.index + 1),
                              style: TextStyle(
                                color: isDark ? Colors.grey[300] : Colors.grey[800],
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(fav.savedAt),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          fontSize: 10,
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

  Widget _buildSettingsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? Colors.black.withOpacity(0.65)
        : Colors.white.withOpacity(0.85);
    final borderColor = isDark ? Colors.blue[900] : Colors.blue[200];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor!, width: 1),
          ),
          child: ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text('Blocked Users'),
            subtitle: const Text('Manage your blocked users'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlockedUsersScreen(
                    currentUserEmail: _user?.email ?? '',
                    databaseService: _databaseService,
                  ),
                ),
              );
            },
          ),
        ),
        // ... rest of the settings section ...
      ],
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
                try {
                  final viewModel = context.read<LoginViewModel>();
                  await viewModel.logout();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginView()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${l10n.error}: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }
} 