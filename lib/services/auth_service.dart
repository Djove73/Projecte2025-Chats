import '../models/user_model.dart';
import 'database_service.dart';
import 'package:dio/dio.dart';

class AuthService {
  final DatabaseService _dbService = DatabaseService();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.86.25:3000',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));
  bool _isInitialized = false;
  List<User> _cachedUsers = [];
  DateTime? _lastCacheUpdate;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _dbService.connect();
      _isInitialized = true;
    }
  }

  Future<List<User>> _updateCache() async {
    try {
      final response = await _dio.get(
        '/auth/all-users',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      
      if (response.statusCode == 200 && response.data is List) {
        _cachedUsers = (response.data as List)
            .map((json) => User.fromJson(json))
            .toList();
        _lastCacheUpdate = DateTime.now();
        return _cachedUsers;
      }
      return [];
    } catch (e) {
      print('Error updating cache: $e');
      return [];
    }
  }

  Future<bool> register(User user) async {
    await _ensureInitialized();
    return await _dbService.registerUser(user);
  }

  Future<User?> login(String email, String password) async {
    await _ensureInitialized();
    return await _dbService.loginUser(email, password);
  }

  Future<void> logout() async {
    if (_isInitialized) {
      await _dbService.disconnect();
      _isInitialized = false;
    }
  }

  Future<bool> updateUser(String email, {String? name, String? newEmail, DateTime? birthDate}) async {
    await _ensureInitialized();
    return await _dbService.updateUser(email, name: name, newEmail: newEmail, birthDate: birthDate);
  }

  Future<bool> sendRecoveryCode(String email) async {
    try {
      final response = await _dio.post(
        '/auth/recovery-code',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw 'No se pudo conectar con el servidor. Verifica tu conexión o la IP del backend.';
      }
      throw 'Error al enviar el código de recuperación: \\n${e.message}';
    } catch (e) {
      throw 'Error inesperado al enviar el código de recuperación: \\n${e.toString()}';
    }
  }

  Future<bool> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw 'Error al restablecer la contraseña';
    }
  }

  Future<bool> deleteAccount(String email) async {
    try {
      final response = await _dio.post(
        '/auth/delete-account',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw 'Error al borrar la cuenta';
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get('/auth/all-users');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => User.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw 'Error fetching users';
    }
  }

  Future<List<User>> searchUsers(String query) async {
    try {
      await _ensureInitialized();
      final users = await _dbService.getAllUsers();
      
      if (query.isEmpty) {
        return users.map((userData) => User.fromJson(userData)).toList();
      }

      return users
          .where((userData) {
            final name = (userData['name'] ?? '').toString().toLowerCase();
            final email = (userData['email'] ?? '').toString().toLowerCase();
            final searchQuery = query.toLowerCase();
            return name.contains(searchQuery) || email.contains(searchQuery);
          })
          .map((userData) => User.fromJson(userData))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  Future<void> updateUserInterests(String email, List<String> interests) async {
    await _dbService.connect();
    await _dbService.updateUserInterests(email, interests);
  }

  Future<bool> followUser(String currentUserEmail, String userToFollowEmail) async {
    await _ensureInitialized();
    return await _dbService.followUser(currentUserEmail, userToFollowEmail);
  }

  Future<bool> unfollowUser(String currentUserEmail, String userToUnfollowEmail) async {
    await _ensureInitialized();
    return await _dbService.unfollowUser(currentUserEmail, userToUnfollowEmail);
  }

  Future<int> getFollowersCount(String userEmail) async {
    await _ensureInitialized();
    return await _dbService.getFollowersCount(userEmail);
  }

  Future<int> getFollowingCount(String userEmail) async {
    await _ensureInitialized();
    return await _dbService.getFollowingCount(userEmail);
  }

  Future<List<User>> getFollowers(String userEmail) async {
    await _ensureInitialized();
    final user = (await _dbService.getAllUsers()).firstWhere((u) => u['email'] == userEmail, orElse: () => {});
    if (user.isEmpty) return [];
    final followersEmails = List<String>.from(user['followers'] ?? []);
    final allUsers = await _dbService.getAllUsers();
    return allUsers.where((u) => followersEmails.contains(u['email'])).map((u) => User.fromJson(u)).toList();
  }

  Future<List<User>> getFollowing(String userEmail) async {
    await _ensureInitialized();
    final user = (await _dbService.getAllUsers()).firstWhere((u) => u['email'] == userEmail, orElse: () => {});
    if (user.isEmpty) return [];
    final followingEmails = List<String>.from(user['following'] ?? []);
    final allUsers = await _dbService.getAllUsers();
    return allUsers.where((u) => followingEmails.contains(u['email'])).map((u) => User.fromJson(u)).toList();
  }
} 