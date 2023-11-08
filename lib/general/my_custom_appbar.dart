import 'package:flutter/material.dart';

AppBar myCustomAppBar(String appbartitle, Color appbarcolor) {
  return AppBar(
    title: Text(appbartitle),
    backgroundColor: appbarcolor,
    leading: null,
  );
}
