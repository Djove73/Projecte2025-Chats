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
      'news1_headline': "Breaking: Major Tech Conference Announced in Barcelona",
      'news1_summary': "The world's leading tech companies will gather in Barcelona for a new global conference. Stay tuned for live updates.",
      'news2_headline': 'Stocks Surge as Markets React to Economic Data',
      'news2_summary': 'Global stock markets are on the rise after positive economic indicators were released this morning.',
      'news3_headline': 'New AI Model Sets Record in Language Understanding',
      'news3_summary': 'Researchers have unveiled an AI model that surpasses previous benchmarks in natural language processing.',
      'news4_headline': 'Sports: Local Team Wins Championship',
      'news4_summary': 'Celebrations erupt as the local football team clinches the national title in a dramatic final.',
      'news5_headline': 'Weather Alert: Heavy Rain Expected Tomorrow',
      'news5_summary': 'Meteorologists warn of heavy rainfall and possible flooding in several regions starting tomorrow.',
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
      'news1_headline': "Última hora: Importante congreso tecnológico anunciado en Barcelona",
      'news1_summary': "Las principales empresas tecnológicas del mundo se reunirán en Barcelona para un nuevo congreso global. Mantente atento para actualizaciones en vivo.",
      'news2_headline': 'Las acciones suben mientras los mercados reaccionan a los datos económicos',
      'news2_summary': 'Los mercados bursátiles globales están en alza tras la publicación de indicadores económicos positivos esta mañana.',
      'news3_headline': 'Nuevo modelo de IA bate récord en comprensión del lenguaje',
      'news3_summary': 'Investigadores han presentado un modelo de IA que supera los anteriores puntos de referencia en procesamiento de lenguaje natural.',
      'news4_headline': 'Deportes: El equipo local gana el campeonato',
      'news4_summary': 'Celebraciones estallan cuando el equipo de fútbol local gana el título nacional en una final dramática.',
      'news5_headline': 'Alerta meteorológica: Se esperan lluvias intensas mañana',
      'news5_summary': 'Los meteorólogos advierten de lluvias intensas y posibles inundaciones en varias regiones a partir de mañana.',
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
      'news1_headline': "Darrera hora: Important congrés tecnològic anunciat a Barcelona",
      'news1_summary': "Les principals empreses tecnològiques del món es reuniran a Barcelona per a un nou congrés global. Estigues atent a les actualitzacions en directe.",
      'news2_headline': 'Les accions pugen mentre els mercats reaccionen a les dades econòmiques',
      'news2_summary': 'Els mercats borsaris globals estan a l’alça després de la publicació d’indicadors econòmics positius aquest matí.',
      'news3_headline': 'Nou model d’IA bat rècord en comprensió del llenguatge',
      'news3_summary': 'Investigadors han presentat un model d’IA que supera els anteriors punts de referència en processament de llenguatge natural.',
      'news4_headline': 'Esports: L’equip local guanya el campionat',
      'news4_summary': 'Celebracions esclaten quan l’equip de futbol local guanya el títol nacional en una final dramàtica.',
      'news5_headline': 'Alerta meteorològica: S’esperen pluges intenses demà',
      'news5_summary': 'Els meteoròlegs adverteixen de pluges intenses i possibles inundacions a diverses regions a partir de demà.',
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
  String getNewsHeadline(int index) => _localizedValues[locale.languageCode]!['news${index}_headline']!;
  String getNewsSummary(int index) => _localizedValues[locale.languageCode]!['news${index}_summary']!;
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