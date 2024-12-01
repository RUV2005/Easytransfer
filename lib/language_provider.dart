import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LanguageProvider with ChangeNotifier {
  String _locale = 'zh';

  String get locale => _locale;

  void setLocale(String locale) {
    _locale = locale;
    Intl.defaultLocale = locale; // 更新 Intl 的默认语言
    notifyListeners(); // 通知监听者
  }
}