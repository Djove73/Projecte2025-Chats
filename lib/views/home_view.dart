import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../viewmodels/login_viewmodel.dart';
import '../views/login_view.dart';
import 'settings_view.dart';
import '../l10n/app_localizations.dart';
import '../viewmodels/favorites_provider.dart';
import '../services/auth_service.dart';
import '../views/notifications_view.dart';
import 'users_list_view.dart';

class HomeView extends StatefulWidget {
  final User user;
  final int? initialNewsIndex;

  // Move newsSamples to the class level
  static final List<Map<String, String>> newsSamples = [
    {
      'headline': "OpenAI lanza GPT-5: el nuevo modelo de IA revoluciona la productividad",
      'summary': "La última versión de GPT promete transformar la forma en que trabajamos y aprendemos, con capacidades aún más avanzadas.",
      'time': 'Hace 2 min',
      'type': 'IA',
    },
    {
      'headline': 'Tesla presenta su coche eléctrico más asequible',
      'summary': 'El nuevo modelo de Tesla busca democratizar el acceso a la movilidad eléctrica en todo el mundo.',
      'time': 'Hace 10 min',
      'type': 'Tecnología',
    },
    {
      'headline': 'El Ibex 35 sube un 3% tras los buenos datos de empleo',
      'summary': 'La bolsa española reacciona positivamente a la recuperación económica y los nuevos datos de empleo.',
      'time': 'Hace 20 min',
      'type': 'Finanzas',
    },
    {
      'headline': 'El Barça gana la Champions en una final histórica',
      'summary': 'El equipo azulgrana conquista Europa tras un partido épico decidido en los penaltis.',
      'time': 'Hace 1 h',
      'type': 'Deportes',
    },
    {
      'headline': 'Alerta meteorológica: ola de calor en toda la península',
      'summary': 'Las autoridades recomiendan extremar precauciones ante las altas temperaturas previstas para esta semana.',
      'time': 'Hace 2 h',
      'type': 'Actualidad',
    },
    {
      'headline': 'Descubren una nueva partícula en el CERN',
      'summary': 'Científicos del CERN anuncian el hallazgo de una partícula subatómica que podría cambiar la física moderna.',
      'time': 'Hace 3 h',
      'type': 'Ciencia',
    },
    {
      'headline': 'Los destinos más populares para viajar este verano',
      'summary': 'Una guía de los lugares más demandados por los viajeros en 2024.',
      'time': 'Hace 4 h',
      'type': 'Viajes',
    },
    {
      'headline': 'Nuevos avances en medicina personalizada',
      'summary': 'La medicina personalizada permite tratamientos más efectivos y menos invasivos.',
      'time': 'Hace 5 h',
      'type': 'Salud',
    },
    {
      'headline': 'La película del año arrasa en taquilla',
      'summary': 'El último estreno de Hollywood bate récords de recaudación en su primer fin de semana.',
      'time': 'Hace 6 h',
      'type': 'Entretenimiento',
    },
  ];

  const HomeView({super.key, required this.user, this.initialNewsIndex});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  int? _highlightedNewsIndex;
  final TextEditingController _searchController = TextEditingController();
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showNewsHeader = true;
  int _followersCount = 0;
  int _followingCount = 0;
  final GlobalKey<SettingsViewState> _settingsKey = GlobalKey<SettingsViewState>();

  @override
  void initState() {
    super.initState();
    _initializeCounters();
    if (widget.initialNewsIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = 0;
          _highlightedNewsIndex = widget.initialNewsIndex;
        });
        _scrollToNews(widget.initialNewsIndex!);
      });
    }
    _initializeSearch();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToNews(int index) {
    _scrollController.animateTo(
      index * 170.0, // Aproximación de altura de cada card
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final viewModel = context.read<LoginViewModel>();
      await viewModel.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _initializeSearch() async {
    setState(() => _isLoading = true);
    try {
      final users = await AuthService().searchUsers('');
      if (mounted) {
        setState(() {
          _allUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    setState(() {
      _searchQuery = query.toLowerCase();
      _isLoading = true;
    });
    
    try {
      final users = await AuthService().searchUsers(query);
      if (mounted) {
        setState(() {
          _filteredUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _filteredUsers = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar usuarios: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _initializeCounters() async {
    final authService = AuthService();
    final followersCount = await authService.getFollowersCount(widget.user.email);
    final followingCount = await authService.getFollowingCount(widget.user.email);
    setState(() {
      _followersCount = followersCount;
      _followingCount = followingCount;
    });
  }

  void _updateCounters() async {
    await _initializeCounters();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Filtrar noticias según intereses del usuario
    final List<String> userInterests = widget.user.interests;
    final List<Map<String, String>> filteredNews = userInterests.isEmpty
        ? HomeView.newsSamples
        : HomeView.newsSamples.where((n) => userInterests.contains(n['type'])).toList();
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232946),
        elevation: 0.5,
        title: Text(
          _selectedIndex == 1 ? 'Ajustes' : _selectedIndex == 2 ? 'Usuarios' : 'REDS',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotificationsView()),
              );
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: l10n.logout,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Material(
                    color: const Color(0xFF232946),
                    borderRadius: BorderRadius.circular(30),
                    elevation: 2,
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Buscar usuarios...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.search, color: Colors.blue),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged();
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      onChanged: (value) => _onSearchChanged(),
                    ),
                  ),
                ),
                if (_showNewsHeader)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF232946),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                child: Text(
                                  'Noticias que te puedan interesar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _showNewsHeader = false;
                                  });
                                },
                                tooltip: 'Cerrar',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 135,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredNews.length,
                            separatorBuilder: (context, i) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final news = filteredNews[index];
                              return Container(
                                width: 230,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF23242A),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      news['headline']!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      news['summary']!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        news['time']!,
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Buscando usuarios...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _searchController.text.isEmpty
                          ? const Center(
                              child: Text(
                                'Escribe para buscar usuarios...',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : _filteredUsers.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No se encontraron usuarios',
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = _filteredUsers[index];
                                    return Card(
                                      elevation: 3,
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blue.shade100,
                                          child: Text(
                                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                          ),
                                        ),
                                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text(user.email),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.message_outlined),
                                          onPressed: () {
                                            // TODO: Implementar funcionalidad de mensaje
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Funcionalidad de mensaje en desarrollo')),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            )
          : _selectedIndex == 1
              ? SettingsView(user: widget.user, followersCount: _followersCount, followingCount: _followingCount)
              : UsersListView(currentUserEmail: widget.user.email, onFollowChanged: _updateCounters),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.processing)),
                );
              },
              child: const Icon(Icons.add),
              tooltip: l10n.save,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.welcome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Usuarios',
          ),
        ],
      ),
    );
  }
} 