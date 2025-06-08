import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F6FF),
        elevation: 0.5,
        title: const Text(
          'Buzón de notificaciones',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 1.2,
            color: Color(0xFF1A237E),
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'No hay notificaciones',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
} 