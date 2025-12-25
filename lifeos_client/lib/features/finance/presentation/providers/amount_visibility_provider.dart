import 'package:flutter/material.dart';

class AmountVisibilityProvider extends ChangeNotifier {
  bool _isVisible = false;

  bool get isVisible => _isVisible;

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  void show() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  void hide() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }
}
