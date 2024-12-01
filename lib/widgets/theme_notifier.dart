import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ValueNotifier<bool> {
  static final ThemeNotifier instance = ThemeNotifier._().._loadSettings();

  ThemeNotifier._() : super(true);

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getBool('followSystemTheme') ?? true;
  }

  Future<void> saveSettings(bool value) async {
    this.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('followSystemTheme', value);
  }
}