import 'package:balsas/page.dart';
import 'package:balsas/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeMode = await _getSavedThemeMode();
  runApp(ThemeProviderWidget(initialThemeMode: themeMode));
}

class ThemeProvider extends InheritedWidget {
  final ThemeMode themeMode;
  final Function(bool) toggleTheme;

  const ThemeProvider({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  const MyApp({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Balsas',
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: themeProvider.themeMode,
      home: BalsasView(
        controller: BalsasController(),
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.deepPurple,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.grey.shade800),
        trackColor: WidgetStateProperty.all(Colors.grey.shade200),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
        headlineMedium: TextStyle(color: Colors.deepPurple, fontSize: 24),
      ),
      primaryColor: Colors.grey.shade700,
      highlightColor: Colors.black,
      cardColor: Colors.grey.shade400,
      scaffoldBackgroundColor: Colors.white,
      hintColor: Colors.grey.shade400,
      useMaterial3: true,
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
        headlineMedium: TextStyle(color: Colors.deepPurple, fontSize: 24),
      ),
      primaryColor: Colors.white54,
      highlightColor: Colors.grey.shade100,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.grey.shade500),
        trackColor: WidgetStateProperty.all(Colors.grey.shade800),
      ),
      cardColor: Colors.grey.shade800,
      scaffoldBackgroundColor: const Color(0xFF2C2C34),
      hintColor: Colors.grey.shade600,
      useMaterial3: true,
    );
  }
}

Future<ThemeMode> _getSavedThemeMode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  return isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
