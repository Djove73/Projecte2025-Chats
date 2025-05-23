import '../models/user_model.dart';

class AuthService {
  // TODO: Implement actual authentication logic with backend
  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> register(User user) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
} 