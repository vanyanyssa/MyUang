import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/settings_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SettingsRepository settingsRepository;

  ThemeCubit({required this.settingsRepository, ThemeMode initialTheme = ThemeMode.system})
      : super(initialTheme);

  Future<void> loadTheme() async {
    final theme = await settingsRepository.getThemeMode();
    emit(theme);
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    await settingsRepository.setThemeMode(mode);
  }
}
