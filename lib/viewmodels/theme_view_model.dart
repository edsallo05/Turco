import 'package:flutter/material.dart';

/// Modo de tema de la app: sistema, claro u oscuro.
class ThemeViewModel extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }
}
