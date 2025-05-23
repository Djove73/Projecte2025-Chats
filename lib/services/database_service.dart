import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';

class DatabaseService {
  static const String _connectionString = 'mongodb+srv://rogerjove2005:rogjov01@cluster0.rxxyf.mongodb.net/';
  static const String _dbName = 'Projecte2025Chats';
  static const String _usersCollection = 'users';
  
  late Db _db;
  late DbCollection _users;

  Future<void> connect() async {
    try {
      _db = await Db.create('$_connectionString$_dbName');
      await _db.open();
      
      // Get or create the users collection
      _users = _db.collection(_usersCollection);
      
      // Create indexes for better performance and data integrity
      await _createIndexes();
      
      print('Connected to MongoDB and initialized users collection');
    } catch (e) {
      print('Error connecting to MongoDB: $e');
      rethrow;
    }
  }

  Future<void> _createIndexes() async {
    try {
      // Create a unique index on email to prevent duplicates
      await _users.createIndex(
        keys: {'email': 1},
        unique: true,
        name: 'email_unique_index'
      );
      
      // Create an index on createdAt for better query performance
      await _users.createIndex(
        keys: {'createdAt': 1},
        name: 'created_at_index'
      );
      
      print('Created indexes for users collection');
    } catch (e) {
      print('Error creating indexes: $e');
      // Don't rethrow here as the collection might already have indexes
    }
  }

  Future<void> disconnect() async {
    await _db.close();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<bool> registerUser(User user) async {
    try {
      // Check if user already exists
      final existingUser = await _users.findOne(where.eq('email', user.email));
      if (existingUser != null) {
        throw Exception('User with this email already exists');
      }

      // Create user document with additional metadata
      final userDoc = {
        'email': user.email,
        'password': _hashPassword(user.password),
        'name': user.name,
        'birthDate': user.birthDate.toIso8601String(),
        'acceptedTerms': user.acceptedTerms,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': null,
        'isActive': true,
        'role': 'user',
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _users.insert(userDoc);
      return true;
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      final userDoc = await _users.findOne(where
          .eq('email', email)
          .eq('password', hashedPassword)
          .eq('isActive', true));

      if (userDoc == null) {
        return null;
      }

      // Update last login timestamp
      await _users.update(
        where.id(userDoc['_id']),
        modify.set('lastLogin', DateTime.now().toIso8601String())
      );

      return User(
        email: userDoc['email'],
        password: userDoc['password'],
        name: userDoc['name'],
        birthDate: DateTime.parse(userDoc['birthDate']),
        acceptedTerms: userDoc['acceptedTerms'],
      );
    } catch (e) {
      print('Error logging in user: $e');
      rethrow;
    }
  }

  // Helper method to get all users (for admin purposes)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final users = await _users.find().toList();
      return users.map((user) {
        // Remove sensitive information
        user.remove('password');
        return user;
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      rethrow;
    }
  }
} 