import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _dbService = DatabaseService();
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
} 