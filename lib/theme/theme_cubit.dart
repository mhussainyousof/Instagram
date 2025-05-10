import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/theme/dark_mode.dart';
import 'package:instagram/theme/light_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeCubit extends Cubit<ThemeData> {
  static const _prefKey = 'isDarkMode';
  bool _isDarkMode = false;

  ThemeCubit() : super(lightMode) {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, _isDarkMode);
    emit(_isDarkMode ? darkMode : lightMode);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_prefKey) ?? false;
    emit(_isDarkMode ? darkMode : lightMode);
  }
}
