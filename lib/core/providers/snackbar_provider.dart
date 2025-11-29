import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnackBarState {
  final String message;
  final Color backgroundColor;

  SnackBarState({required this.message, this.backgroundColor = Colors.black});
}

class SnackBarNotifier extends StateNotifier<SnackBarState?> {
  SnackBarNotifier() : super(null);

  void show(String message, {Color backgroundColor = Colors.black}) {
    state = SnackBarState(message: message, backgroundColor: backgroundColor);
  }

  void clear() {
    state = null;
  }
}

final snackBarProvider =
    StateNotifierProvider<SnackBarNotifier, SnackBarState?>((ref) {
      return SnackBarNotifier();
    });
