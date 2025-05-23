import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> register(
    String email,
    String password,
    String name,
    DateTime birthDate,
    bool acceptedTerms,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = User(
        email: email,
        password: password,
        name: name,
        birthDate: birthDate,
        acceptedTerms: acceptedTerms,
      );
      final success = await _authService.register(user);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
} 