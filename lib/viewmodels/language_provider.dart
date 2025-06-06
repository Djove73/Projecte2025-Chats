import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('es');

  Locale get currentLocale => _currentLocale;

  void setLocale(String languageCode) {
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }
} 