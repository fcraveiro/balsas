import 'package:balsas/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProviderWidget extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const ThemeProviderWidget({super.key, required this.initialThemeMode});

  @override
  State<ThemeProviderWidget> createState() => _ThemeProviderWidgetState();
}

class _ThemeProviderWidgetState extends State<ThemeProviderWidget> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void _toggleTheme(bool isDarkMode) async {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeMode: _themeMode,
      toggleTheme: _toggleTheme,
      child: MyApp(themeMode: _themeMode),
    );
  }
}
