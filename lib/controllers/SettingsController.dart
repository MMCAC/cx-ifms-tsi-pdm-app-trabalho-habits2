import 'package:trabalho/models/UserSettings.dart';
import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  UserSettings _settings = UserSettings(
    name: 'Maicon',
    icon: Icons.person,
    color: Color.fromARGB(255, 0, 79, 197),
  );

  UserSettings get settings => _settings;

  void updateName(String name) {
    _settings.name = name;
    notifyListeners();
  }

  void updateIcon(IconData icon) {
    _settings.icon = icon;
    notifyListeners();
  }

  void updateColor(Color color) {
    _settings.color = color;
    notifyListeners();
  }
}