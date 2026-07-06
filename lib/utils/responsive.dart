import 'package:flutter/material.dart';

class Responsive {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600;

  static double horizontalPadding(BuildContext context) {
    return isTablet(context) ? 32 : 20;
  }

  static double cardRadius(BuildContext context) {
    return isTablet(context) ? 30 : 22;
  }

  static double titleFont(BuildContext context) {
    return isTablet(context) ? 24 : 20;
  }

  static double valueFont(BuildContext context) {
    return isTablet(context) ? 38 : 30;
  }
}