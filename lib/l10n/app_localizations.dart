import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'name': 'Name',
      'email': 'Email',
      'birthDate': 'Birth Date',
      'save': 'Save',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'logout': 'Logout',
      'welcome': 'Welcome',
      'login': 'Login',
      'register': 'Register',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'processing': 'Processing...',
      'error': 'Error',
      'success': 'Success',
    },
    'es': {
      'settings': 'Ajustes',
      'language': 'Idioma',
      'theme': 'Tema',
      'darkMode': 'Modo Oscuro',
      'lightMode': 'Modo Claro',
      'name': 'Nombre',
      'email': 'Correo',
      'birthDate': 'Fecha de Nacimiento',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'edit': 'Editar',
      'logout': 'Cerrar Sesión',
      'welcome': 'Bienvenido',
      'login': 'Iniciar Sesión',
      'register': 'Registrarse',
      'password': 'Contraseña',
      'forgotPassword': '¿Olvidaste tu contraseña?',
      'processing': 'Procesando...',
      'error': 'Error',
      'success': 'Éxito',
    },
    'ca': {
      'settings': 'Ajustos',
      'language': 'Idioma',
      'theme': 'Tema',
      'darkMode': 'Mode Fosc',
      'lightMode': 'Mode Clar',
      'name': 'Nom',
      'email': 'Correu',
      'birthDate': 'Data de Naixement',
      'save': 'Desar',
      'cancel': 'Cancel·lar',
      'edit': 'Editar',
      'logout': 'Tancar Sessió',
      'welcome': 'Benvingut',
      'login': 'Iniciar Sessió',
      'register': 'Registrar-se',
      'password': 'Contrasenya',
      'forgotPassword': 'Has oblidat la contrasenya?',
      'processing': 'Processant...',
      'error': 'Error',
      'success': 'Èxit',
    },
  };

  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get darkMode => _localizedValues[locale.languageCode]!['darkMode']!;
  String get lightMode => _localizedValues[locale.languageCode]!['lightMode']!;
  String get name => _localizedValues[locale.languageCode]!['name']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get birthDate => _localizedValues[locale.languageCode]!['birthDate']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get forgotPassword => _localizedValues[locale.languageCode]!['forgotPassword']!;
  String get processing => _localizedValues[locale.languageCode]!['processing']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'ca'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
} 