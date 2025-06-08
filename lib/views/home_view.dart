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

class HomeView extends StatefulWidget {
  final User user;
  final int? initialNewsIndex;

  // Move newsSamples to the class level
  static final List<Map<String, String>> newsSamples = [
    {
      'headline': "OpenAI lanza GPT-5: el nuevo modelo de IA revoluciona la productividad",
      'summary': "La última versión de GPT promete transformar la forma en que trabajamos y aprendemos, con capacidades aún más avanzadas.",
      'time': 'Hace 2 min',
      'type': 'ai',
    },
    {
      'headline': 'Tesla presenta su coche eléctrico más asequible',
      'summary': 'El nuevo modelo de Tesla busca democratizar el acceso a la movilidad eléctrica en todo el mundo.',
      'time': 'Hace 10 min',
      'type': 'tech',
    },
    {
      'headline': 'El Ibex 35 sube un 3% tras los buenos datos de empleo',
      'summary': 'La bolsa española reacciona positivamente a la recuperación económica y los nuevos datos de empleo.',
      'time': 'Hace 20 min',
      'type': 'finance',
    },
    {
      'headline': 'El Barça gana la Champions en una final histórica',
      'summary': 'El equipo azulgrana conquista Europa tras un partido épico decidido en los penaltis.',
      'time': 'Hace 1 h',
      'type': 'sports',
    },
    {
      'headline': 'Alerta meteorológica: ola de calor en toda la península',
      'summary': 'Las autoridades recomiendan extremar precauciones ante las altas temperaturas previstas para esta semana.',
      'time': 'Hace 2 h',
      'type': 'weather',
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

  @override
  void initState() {
    super.initState();
    if (widget.initialNewsIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = 0;
          _highlightedNewsIndex = widget.initialNewsIndex;
        });
        _scrollToNews(widget.initialNewsIndex!);
      });
    }
    _fetchUsers();
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

  void _onSearchChanged() async {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _isLoading = true;
    });
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredUsers = [];
        _isLoading = false;
      });
      return;
    }
    try {
      final users = await AuthService().searchUsers(_searchQuery);
      setState(() {
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _filteredUsers = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await AuthService().getAllUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<Map<String, String>> localizedNews = List.generate(5, (i) => {
      'headline': l10n.getNewsHeadline(i + 1),
      'summary': l10n.getNewsSummary(i + 1),
      'time': HomeView.newsSamples[i]['time']!,
      'type': HomeView.newsSamples[i]['type']!,
    });
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232946),
        elevation: 0.5,
        title: Text(
          _selectedIndex == 1 ? 'Ajustes' : 'REDS',
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
                        hintText: 'Search users...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.search, color: Colors.blue),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
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
                    ),
                  ),
                ),
                if (_showNewsHeader)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: Container(
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
                  ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _searchController.text.isEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: HomeView.newsSamples.length,
                              itemBuilder: (context, index) {
                                final news = HomeView.newsSamples[index];
                                return _buildNewsCard(context, news: news, index: index);
                              },
                            )
                          : _filteredUsers.isEmpty
                              ? const Center(child: Text('No users found', style: TextStyle(fontSize: 18, color: Colors.grey)))
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
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            )
          : SettingsView(user: widget.user),
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
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, {required Map<String, String> news, int? index, bool highlight = false}) {
    final l10n = AppLocalizations.of(context);
    IconData icon;
    Color iconColor;
    switch (news['type']) {
      case 'tech':
        icon = Icons.memory;
        iconColor = Colors.purpleAccent;
        break;
      case 'finance':
        icon = Icons.trending_up;
        iconColor = Colors.greenAccent;
        break;
      case 'ai':
        icon = Icons.smart_toy;
        iconColor = Colors.deepPurpleAccent;
        break;
      case 'sports':
        icon = Icons.sports_soccer;
        iconColor = Colors.orangeAccent;
        break;
      case 'weather':
        icon = Icons.cloud;
        iconColor = Colors.lightBlueAccent;
        break;
      default:
        icon = Icons.flash_on;
        iconColor = Colors.redAccent;
    }
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final newsIndex = index ?? 0;
    final isFavorite = favoritesProvider.isFavorite(newsIndex);
    return Card(
      color: highlight ? Colors.amber[100] : const Color(0xFF23242A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: highlight ? 12 : 6,
      margin: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          setState(() {
            _highlightedNewsIndex = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.processing}: ${news['headline']}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      news['headline']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: isFavorite ? Colors.amber : Colors.grey[400],
                      size: 22,
                    ),
                    tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                    onPressed: () {
                      favoritesProvider.toggleFavorite(newsIndex);
                    },
                  ),
                  Text(
                    news['time']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[200],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                news['summary']!,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new, size: 18, color: Colors.white),
                  label: Text(l10n.save),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    elevation: 0,
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