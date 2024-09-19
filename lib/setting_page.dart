import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balsas/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = false;
  int _updateInterval = 60;
  final TextEditingController _intervalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('notifications') ?? false;
      _updateInterval = prefs.getInt('updateInterval') ?? 60;
      _intervalController.text = _updateInterval.toString();
    });
  }

  goBack() {
    Future.delayed(Duration.zero, () {
      Navigator.pop(context, 'Yep!');
    });
  }

  _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notifications);
    await prefs.setInt('updateInterval', _updateInterval);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurações',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tema Escuro'),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text('Intervalo de Atualização (segundos):'),
            const SizedBox(height: 10),
            TextField(
              controller: _intervalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Digite o intervalo em segundos',
              ),
              onChanged: (value) {
                setState(() {
                  _updateInterval = int.tryParse(value) ?? 60;
                });
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}
