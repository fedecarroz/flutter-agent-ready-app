import 'package:bloc/bloc.dart';

/// Holds whether dark mode is enabled.
class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(false);

  void toggleDarkMode() => emit(!state);
}
