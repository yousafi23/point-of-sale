// import 'package:flutter/material.dart';

// SnackBar myCustomSnackBar({required String message, required bool warning}) {
//   return SnackBar(
//     content: Text(message,
//         textAlign: TextAlign.center,
//         style: TextStyle(fontSize: warning ? 20 : 15)),
//     backgroundColor: warning
//         ? const Color.fromARGB(255, 255, 64, 64)
//         : const Color.fromARGB(255, 35, 193, 11),
//     // duration: const Duration(milliseconds: 100),
//   );
// }

import 'package:flutter/material.dart';

void myCustomSnackBar(
    {required BuildContext context,
    required String message,
    required bool warning,
    int? duration}) {
  // remove the current snackbar, if any
  ScaffoldMessenger.of(context).removeCurrentSnackBar();

  // Show the new snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      showCloseIcon: true,
      behavior: SnackBarBehavior.floating,
      content: Text(message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: warning ? 20 : 15)),
      backgroundColor: warning ? Colors.red : Colors.green,
      duration: duration != null
          ? Duration(seconds: duration)
          : const Duration(seconds: 3),
    ),
  );
}
