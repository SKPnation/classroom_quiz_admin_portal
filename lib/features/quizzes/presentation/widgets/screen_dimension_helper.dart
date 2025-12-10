import 'package:flutter/material.dart';

class Breakpoints {
  static bool isDesktop(BuildContext c) => MediaQuery.of(c).size.width >= 1100;

  static bool isTablet(BuildContext c) =>
      MediaQuery.of(c).size.width >= 768 && MediaQuery.of(c).size.width < 1100;

  static bool isNarrow(BuildContext c) => MediaQuery.of(c).size.width < 768;
}