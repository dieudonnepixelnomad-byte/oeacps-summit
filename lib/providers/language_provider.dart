import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('fr');

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;

  LanguageProvider() {
    _loadLanguage();
  }

  bool _isLanguageSet = false;
  bool get isLanguageSet => _isLanguageSet;

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('language_code')) {
      final langCode = prefs.getString('language_code')!;
      _currentLocale = Locale(langCode);
      _isLanguageSet = true;
    } else {
      _currentLocale = const Locale('fr');
      _isLanguageSet = false;
    }
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    _currentLocale = Locale(langCode);
    _isLanguageSet = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    notifyListeners();
  }
  
  /// Méthode pour vérifier explicitement si une langue est déjà configurée
  Future<bool> checkLanguageSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('language_code');
  }
}
