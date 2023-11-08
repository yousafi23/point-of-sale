import 'package:flutter/material.dart';

SnackBar myCustomSnackBar({required String message, required bool warning}) {
  return SnackBar(
    content: Text(message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: warning ? 20 : 15)),
    backgroundColor: warning
        ? Color.fromARGB(255, 255, 64, 64)
        : Color.fromARGB(255, 35, 193, 11),
  );
}
