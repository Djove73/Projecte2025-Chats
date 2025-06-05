import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../viewmodels/login_viewmodel.dart';
import '../views/login_view.dart';

class HomeView extends StatelessWidget {
  final User user;

  // Move newsSamples to the class level
  static final List<Map<String, String>> newsSamples = [
    {
      'headline': "Breaking: Major Tech Conference Announced in Barcelona",
      'summary': "The world's leading tech companies will gather in Barcelona for a new global conference. Stay tuned for live updates.",
      'time': 'Just now',
      'type': 'tech',
    },
    {
      'headline': 'Stocks Surge as Markets React to Economic Data',
      'summary': 'Global stock markets are on the rise after positive economic indicators were released this morning.',
      'time': '5 min ago',
      'type': 'finance',
    },
    {
      'headline': 'New AI Model Sets Record in Language Understanding',
      'summary': 'Researchers have unveiled an AI model that surpasses previous benchmarks in natural language processing.',
      'time': '10 min ago',
      'type': 'ai',
    },
    {
      'headline': 'Sports: Local Team Wins Championship',
      'summary': 'Celebrations erupt as the local football team clinches the national title in a dramatic final.',
      'time': '20 min ago',
      'type': 'sports',
    },
    {
      'headline': 'Weather Alert: Heavy Rain Expected Tomorrow',
      'summary': 'Meteorologists warn of heavy rainfall and possible flooding in several regions starting tomorrow.',
      'time': '30 min ago',
      'type': 'weather',
    },
  ];

  const HomeView({super.key, required this.user});

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: \\${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('REDS', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.blue),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: newsSamples.length,
        itemBuilder: (context, index) {
          return _buildNewsCard(context, news: newsSamples[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          // TODO: Implement new post or refresh
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feature coming soon!')),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'New Post',
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, {required Map<String, String> news}) {
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
    return Card(
      color: const Color(0xFF23242A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // TODO: Open news detail
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening: \\${news['headline']}')),
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
                  label: const Text('Read more'),
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