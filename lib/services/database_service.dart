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
    try {
      if (_db.isConnected) {
        await _db.close();
        print('Successfully disconnected from MongoDB');
      }
    } catch (e) {
      print('Error disconnecting from MongoDB: $e');
      rethrow;
    }
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
        'interests': user.interests,
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
      // Special case for admin user
      if (email == 'admin' && password == '1234') {
        return User(
          email: 'admin',
          password: _hashPassword('1234'),
          name: 'Administrator',
          birthDate: DateTime(2000, 1, 1),
          acceptedTerms: true,
        );
      }

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

  Future<bool> updateUser(String email, {String? name, String? newEmail, DateTime? birthDate}) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (newEmail != null) updateData['email'] = newEmail;
      if (birthDate != null) updateData['birthDate'] = birthDate.toIso8601String();
      updateData['updatedAt'] = DateTime.now().toIso8601String();
      // Build the modifier by chaining .set for each field
      var modifier = modify;
      updateData.forEach((key, value) {
        modifier = modifier.set(key, value);
      });
      final result = await _users.update(
        where.eq('email', email),
        modifier,
      );
      // Check if any document was modified
      return (result['nModified'] ?? result['n'] ?? 0) > 0;
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<bool> blockUser(String currentUserEmail, String userToBlockEmail) async {
    try {
      final result = await _users.update(
        where.eq('email', currentUserEmail),
        modify.addToSet('blockedUsers', userToBlockEmail),
      );
      return (result['nModified'] ?? result['n'] ?? 0) > 0;
    } catch (e) {
      print('Error blocking user: $e');
      rethrow;
    }
  }

  Future<bool> unblockUser(String currentUserEmail, String userToUnblockEmail) async {
    try {
      final result = await _users.update(
        where.eq('email', currentUserEmail),
        modify.pull('blockedUsers', userToUnblockEmail),
      );
      return (result['nModified'] ?? result['n'] ?? 0) > 0;
    } catch (e) {
      print('Error unblocking user: $e');
      rethrow;
    }
  }

  Future<bool> reportUser(String currentUserEmail, String userToReportEmail) async {
    try {
      final result = await _users.update(
        where.eq('email', currentUserEmail),
        modify.addToSet('reportedUsers', userToReportEmail),
      );
      return (result['nModified'] ?? result['n'] ?? 0) > 0;
    } catch (e) {
      print('Error reporting user: $e');
      rethrow;
    }
  }

  Future<List<String>> getBlockedUsers(String userEmail) async {
    try {
      final user = await _users.findOne(where.eq('email', userEmail));
      if (user == null) return [];
      return List<String>.from(user['blockedUsers'] ?? []);
    } catch (e) {
      print('Error getting blocked users: $e');
      rethrow;
    }
  }

  Future<List<String>> getReportedUsers(String userEmail) async {
    try {
      final user = await _users.findOne(where.eq('email', userEmail));
      if (user == null) return [];
      return List<String>.from(user['reportedUsers'] ?? []);
    } catch (e) {
      print('Error getting reported users: $e');
      rethrow;
    }
  }

  Future<void> updateUserInterests(String email, List<String> interests) async {
    await _users.update(
      where.eq('email', email),
      modify.set('interests', interests),
    );
  }

  Future<bool> followUser(String currentUserEmail, String userToFollowEmail) async {
    try {
      // Add userToFollowEmail to currentUser's following
      await _users.update(
        where.eq('email', currentUserEmail),
        modify.addToSet('following', userToFollowEmail),
      );
      // Add currentUserEmail to userToFollow's followers
      await _users.update(
        where.eq('email', userToFollowEmail),
        modify.addToSet('followers', currentUserEmail),
      );
      return true;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }

  Future<bool> unfollowUser(String currentUserEmail, String userToUnfollowEmail) async {
    try {
      // Remove userToUnfollowEmail from currentUser's following
      await _users.update(
        where.eq('email', currentUserEmail),
        modify.pull('following', userToUnfollowEmail),
      );
      // Remove currentUserEmail from userToUnfollow's followers
      await _users.update(
        where.eq('email', userToUnfollowEmail),
        modify.pull('followers', currentUserEmail),
      );
      return true;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }

  Future<int> getFollowersCount(String userEmail) async {
    final user = await _users.findOne(where.eq('email', userEmail));
    return user != null && user['followers'] != null ? (user['followers'] as List).length : 0;
  }

  Future<int> getFollowingCount(String userEmail) async {
    final user = await _users.findOne(where.eq('email', userEmail));
    return user != null && user['following'] != null ? (user['following'] as List).length : 0;
  }
} 