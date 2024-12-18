import 'package:flutter/material.dart';

class Global {
  static const String appTitle = "G Notes";
  static const String dbName = 'notes';
  static const String tableName = 'lists';

  static bool isEditingInProgress = false;

  static List<Color> tileColors = [
    Colors.lightBlue[100]!,
    Colors.purple[100]!,
    Colors.teal[100]!,
    Colors.green[100]!,
    Colors.pink[100]!,
    Colors.cyan[100]!,
    Colors.indigo[100]!,
    Colors.lightGreen[100]!,
    Colors.amber[100]!,
    Colors.lime[100]!,
    Colors.blueGrey[100]!
  ];
}
