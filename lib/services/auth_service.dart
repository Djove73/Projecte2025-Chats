import '../models/user_model.dart';
import 'database_service.dart';
import 'package:dio/dio.dart';

class AuthService {
  final DatabaseService _dbService = DatabaseService();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.86.25:3000',
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 5),
  ));
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _dbService.connect();
      _isInitialized = true;
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
} 