import 'package:flutter/material.dart';

void authSnackbar(
  BuildContext context,
  String message, {
  required bool isError,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
