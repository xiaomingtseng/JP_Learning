import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.pink,
      brightness: Brightness.light,
    ).copyWith(secondary: Colors.amber),
    brightness: Brightness.light,
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.pink,
      textTheme: ButtonTextTheme.primary,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.deepPurple,
      brightness: Brightness.dark,
    ).copyWith(secondary: Colors.teal),
    brightness: Brightness.dark,
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.deepPurple,
      textTheme: ButtonTextTheme.primary,
    ),
  );
}

class ThemeNotifier with ChangeNotifier {
  final String key = "theme_mode";
  SharedPreferences? _prefs;
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _themeMode = ThemeMode.light; // 預設為亮色模式
    _loadFromPrefs();
  }

  _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    String? themeString = _prefs!.getString(key);
    if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeString == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  _saveToPrefs(ThemeMode themeMode) async {
    await _initPrefs();
    if (themeMode == ThemeMode.dark) {
      _prefs!.setString(key, 'dark');
    } else if (themeMode == ThemeMode.system) {
      _prefs!.setString(key, 'system');
    } else {
      _prefs!.setString(key, 'light');
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveToPrefs(mode);
    notifyListeners();
  }

  // 為了簡化，我們只提供切換亮暗模式的開關
  // 如果需要 "跟隨系統" 選項，UI 會更複雜一些
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // 如果是跟隨系統，則根據系統設定判斷
      // 這需要 BuildContext，通常在 Widget 中獲取
      // WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
      // 為了簡化，這裡假設如果 themeMode 是 system，則不算作 isDarkMode 的 true
      // 實際應用中，SettingsScreen 的開關可能需要三種狀態或一個下拉選單
      return false; // 或者根據實際邏輯調整
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme(bool darkModeOn) {
    setThemeMode(darkModeOn ? ThemeMode.dark : ThemeMode.light);
  }
}
