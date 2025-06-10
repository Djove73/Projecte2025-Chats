import 'dart:math';
import '../models/user_model.dart';
import '../services/database_service.dart';

class TestUserGenerator {
  static final Random _random = Random();
  
  // Common first names
  static final List<String> _firstNames = [
    'Maria', 'Josep', 'Anna', 'Joan', 'Carme', 'Antoni', 'Francesc', 'Jordi',
    'Laura', 'Pere', 'Montserrat', 'Miquel', 'Rosa', 'Carles', 'Núria', 'Albert',
    'Elena', 'David', 'Sara', 'Marc', 'Cristina', 'Javier', 'Paula', 'Daniel',
    'Marta', 'Alejandro', 'Lucía', 'Carlos', 'Sofía', 'Miguel'
  ];

  // Common last names
  static final List<String> _lastNames = [
    'Garcia', 'Martínez', 'Rodríguez', 'Fernández', 'López', 'González', 'Pérez',
    'Gómez', 'Sánchez', 'Díaz', 'Moreno', 'Jiménez', 'Hernández', 'Muñoz', 'Álvarez',
    'Romero', 'Navarro', 'Torres', 'Domínguez', 'Gil', 'Vázquez', 'Serrano', 'Ramos',
    'Blanco', 'Suárez', 'Molina', 'Morales', 'Ortega', 'Delgado', 'Castro'
  ];

  // Common interests
  static final List<String> _interests = [
    'Música', 'Deportes', 'Cine', 'Literatura', 'Viajes', 'Fotografía', 'Cocina',
    'Arte', 'Tecnología', 'Naturaleza', 'Baile', 'Teatro', 'Historia', 'Ciencia',
    'Videojuegos', 'Moda', 'Diseño', 'Idiomas', 'Meditación', 'Yoga'
  ];

  static String _generateEmail(String firstName, String lastName) {
    final domains = ['gmail.com', 'hotmail.com', 'yahoo.com', 'outlook.com', 'icloud.com'];
    final domain = domains[_random.nextInt(domains.length)];
    final number = _random.nextInt(1000);
    return '${firstName.toLowerCase()}.${lastName.toLowerCase()}$number@$domain';
  }

  static String _generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    return List.generate(12, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  static DateTime _generateBirthDate() {
    final now = DateTime.now();
    final minAge = 18;
    final maxAge = 65;
    final randomAge = minAge + _random.nextInt(maxAge - minAge);
    final year = now.year - randomAge;
    final month = 1 + _random.nextInt(12);
    final day = 1 + _random.nextInt(28); // Using 28 to avoid invalid dates
    return DateTime(year, month, day);
  }

  static List<String> _generateInterests() {
    final numInterests = 2 + _random.nextInt(4); // 2-5 interests
    final shuffled = List<String>.from(_interests)..shuffle();
    return shuffled.take(numInterests).toList();
  }

  static User generateUser() {
    final firstName = _firstNames[_random.nextInt(_firstNames.length)];
    final lastName = _lastNames[_random.nextInt(_lastNames.length)];
    final name = '$firstName $lastName';
    
    return User(
      email: _generateEmail(firstName, lastName),
      password: _generatePassword(),
      name: name,
      birthDate: _generateBirthDate(),
      acceptedTerms: true,
      interests: _generateInterests(),
    );
  }
}

Future<void> main() async {
  final dbService = DatabaseService();
  
  try {
    print('Connecting to database...');
    await dbService.connect();
    
    print('Generating and registering 100 test users...');
    for (int i = 0; i < 100; i++) {
      final user = TestUserGenerator.generateUser();
      try {
        await dbService.registerUser(user);
        print('Created user ${i + 1}/100: ${user.email}');
      } catch (e) {
        print('Error creating user ${i + 1}: $e');
      }
    }
    
    print('Successfully created test users!');
  } catch (e) {
    print('Error: $e');
  } finally {
    await dbService.disconnect();
  }
} 