import 'package:flutter/material.dart';

abstract class AppSpacing {
  static const screen = EdgeInsets.symmetric(horizontal: 16);
}

abstract class AppFontSize {
  static const TextStyle helloTexth1 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const TextStyle helloText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
}
