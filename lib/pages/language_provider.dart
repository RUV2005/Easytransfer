import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'zh'; // 默认语言

  String get currentLanguage => _currentLanguage;

  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }
}