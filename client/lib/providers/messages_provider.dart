import 'package:flutter/material.dart';

class MessagesProvider with ChangeNotifier {
  String _message = '';

  String get message => _message;

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }

  void clearMessage() {
    _message = '';
    notifyListeners();
  }
}
