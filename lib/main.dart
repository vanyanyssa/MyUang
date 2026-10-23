import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/database_helper.dart';
import 'data/datasources/settings_local_data_source.dart';
import 'data/datasources/transaction_local_data_source.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/add_transaction.dart';
import 'domain/usecases/delete_transaction.dart';
import 'domain/usecases/get_transactions.dart';
import 'domain/usecases/update_transaction.dart';
import 'presentation/bloc/theme_cubit.dart';
import 'presentation/bloc/transaction_bloc.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final databaseHelper = DatabaseHelper.instance;

  final transactionLocalDataSource = TransactionLocalDataSource(
    databaseHelper: databaseHelper,
  );

  final transactionRepository = TransactionRepositoryImpl(
    localDataSource: transactionLocalDataSource,
  );

  final getTransactions = GetTransactions(transactionRepository);
  final addTransaction = AddTransaction(transactionRepository);
  final updateTransaction = UpdateTransaction(transactionRepository);
  final deleteTransaction = DeleteTransaction(transactionRepository);

  final sharedPreferences = await SharedPreferences.getInstance();
  final settingsLocalDataSource = SettingsLocalDataSource(
    sharedPreferences: sharedPreferences,
  );
  final settingsRepository = SettingsRepositoryImpl(
    localDataSource: settingsLocalDataSource,
  );
  final initialTheme = await settingsRepository.getThemeMode();

  runApp(
    MyUangApp(
      getTransactions: getTransactions,
      addTransaction: addTransaction,
      updateTransaction: updateTransaction,
      deleteTransaction: deleteTransaction,
      settingsRepository: settingsRepository,
      initialTheme: initialTheme,
    ),
  );
}

class MyUangApp extends StatelessWidget {
  final GetTransactions getTransactions;
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;
  final SettingsRepository settingsRepository;
  final ThemeMode initialTheme;

  const MyUangApp({
    super.key,
    required this.getTransactions,
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.settingsRepository,
    required this.initialTheme,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>(
          create: (_) => TransactionBloc(
            getTransactions: getTransactions,
            addTransaction: addTransaction,
            updateTransaction: updateTransaction,
            deleteTransaction: deleteTransaction,
          ),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(
            settingsRepository: settingsRepository,
            initialTheme: initialTheme,
          ),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MyUang',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
