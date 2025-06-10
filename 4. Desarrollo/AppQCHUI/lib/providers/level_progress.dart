import 'package:flutter/material.dart';

class LevelProgress with ChangeNotifier {
  int _level = 0;

  int get level => _level;

  void increment() {
    _level++;
    notifyListeners();
  }
}
