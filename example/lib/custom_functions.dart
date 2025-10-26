import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? snackBarAction,
  int? durationInMillisecond,
  bool? isError,
  EdgeInsetsGeometry margin = const EdgeInsets.all(16),
}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isError != null ? Colors.red : Colors.green,
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      duration: Duration(milliseconds: durationInMillisecond ?? 2000),
      // margin: const EdgeInsets.all(15),
      margin: margin,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      action: snackBarAction,
    ),
  );
}
