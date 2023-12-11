import 'package:flutter/material.dart';

AppBar myCustomAppBar(String appbartitle, Color appbarcolor) {
  return AppBar(
    title: Text(
      appbartitle,
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: appbarcolor,
    leading: null,
  );
}
