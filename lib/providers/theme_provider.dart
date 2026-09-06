import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeBoxName = 'themeBox';
  static const String _themeKey = 'isDarkMode';
  
  bool _isDarkMode = false;
  late Box _themeBox;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _themeBox = await Hive.openBox(_themeBoxName);
    _isDarkMode = _themeBox.get(_themeKey, defaultValue: false);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _themeBox.put(_themeKey, _isDarkMode);
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F1EA),
        primaryColor: const Color(0xFF1F6D5A),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1F6D5A),
          secondary: Color(0xFFD9785B),
          surface: Color(0xFFFCFAF6),
          onSurface: Color(0xFF20251F),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE3DED4)),
          ),
          color: const Color(0xFFFCFAF6),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFFF4F1EA),
          foregroundColor: Color(0xFF20251F),
          centerTitle: true,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE3DED4),
          space: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0ECE4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1F6D5A), width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1F6D5A),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1F6D5A),
            side: const BorderSide(color: Color(0xFFB8CFC5)),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFCFAF6),
          selectedItemColor: Color(0xFF1F6D5A),
          unselectedItemColor: Color(0xFF8A8F87),
          type: BottomNavigationBarType.fixed,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1F6D5A),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF20251F),
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF20251F),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF20251F),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF646A62),
          ),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF151A17),
        primaryColor: const Color(0xFF78C7A7),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF78C7A7),
          secondary: Color(0xFFE39A7D),
          surface: Color(0xFF202722),
          onSurface: Color(0xFFE8EEE8),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF354139)),
          ),
          color: const Color(0xFF202722),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF151A17),
          foregroundColor: Color(0xFFE8EEE8),
          centerTitle: true,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF354139),
          space: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF202722),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF78C7A7), width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF78C7A7),
            foregroundColor: const Color(0xFF102019),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF78C7A7),
            side: const BorderSide(color: Color(0xFF4C7561)),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF202722),
          selectedItemColor: Color(0xFF78C7A7),
          unselectedItemColor: Color(0xFF849187),
          type: BottomNavigationBarType.fixed,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF78C7A7),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE8EEE8),
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE8EEE8),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFFE8EEE8),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFFADB9AF),
          ),
        ),
      );

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
}
