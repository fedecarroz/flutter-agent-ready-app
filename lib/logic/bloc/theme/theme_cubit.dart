import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

/// Holds the current app [ThemeMode].
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit([super.initialMode = ThemeMode.light]);

  /// Sets the app theme to [mode].
  ///
  /// If the current theme already matches [mode], does nothing.
  void setTheme(ThemeMode mode) {
    if (state == mode) return;
    emit(mode);
  }
}
