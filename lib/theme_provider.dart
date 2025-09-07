import 'package:flutter/material.dart';

enum AppTheme { light, dark, gamified }

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  AppTheme _appTheme = AppTheme.light;

  ThemeMode get themeMode => _themeMode;
  AppTheme get appTheme => _appTheme;
  bool get isGamified => _appTheme == AppTheme.gamified;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  void setDayTheme() {
    _themeMode = ThemeMode.light;
    _appTheme = AppTheme.light;
    notifyListeners();
  }

  void setDarkTheme() {
    _themeMode = ThemeMode.dark;
    _appTheme = AppTheme.dark;
    notifyListeners();
  }

  void setGamifiedTheme() {
    _themeMode = ThemeMode.light;
    _appTheme = AppTheme.gamified;
    notifyListeners();
  }
}
