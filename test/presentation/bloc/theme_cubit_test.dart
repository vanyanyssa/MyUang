import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myuang/domain/repositories/settings_repository.dart';
import 'package:myuang/presentation/bloc/theme_cubit.dart';

class FakeSettingsRepository implements SettingsRepository {
  ThemeMode _mode = ThemeMode.system;

  @override
  Future<ThemeMode> getThemeMode() async => _mode;

  @override
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _mode = themeMode;
  }
}

void main() {
  group('ThemeCubit Tests', () {
    late FakeSettingsRepository repository;
    late ThemeCubit cubit;

    setUp(() {
      repository = FakeSettingsRepository();
      cubit = ThemeCubit(settingsRepository: repository, initialTheme: ThemeMode.system);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state matches initialTheme', () {
      expect(cubit.state, ThemeMode.system);
    });

    test('setTheme updates state and saves to repository', () async {
      await cubit.setTheme(ThemeMode.dark);
      expect(cubit.state, ThemeMode.dark);
      expect(await repository.getThemeMode(), ThemeMode.dark);

      await cubit.setTheme(ThemeMode.light);
      expect(cubit.state, ThemeMode.light);
      expect(await repository.getThemeMode(), ThemeMode.light);
    });

    test('loadTheme loads state from repository', () async {
      await repository.setThemeMode(ThemeMode.dark);
      await cubit.loadTheme();
      expect(cubit.state, ThemeMode.dark);
    });
  });
}
