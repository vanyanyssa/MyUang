import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/theme_cubit.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tampilan / Tema
          const Text(
            'TAMPILAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, currentMode) {
              return Card(
                child: RadioGroup<ThemeMode>(
                  groupValue: currentMode,
                  onChanged: (mode) {
                    if (mode != null) {
                      context.read<ThemeCubit>().setTheme(mode);
                    }
                  },
                  child: const Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        title: Text('Ikuti Pengaturan Sistem'),
                        subtitle: Text('Menyesuaikan tema otomatis dari perangkat'),
                        secondary: Icon(Icons.brightness_auto_outlined),
                        value: ThemeMode.system,
                      ),
                      Divider(height: 1),
                      RadioListTile<ThemeMode>(
                        title: Text('Tema Terang'),
                        subtitle: Text('Tampilan bersih dan cerah'),
                        secondary: Icon(Icons.light_mode_outlined),
                        value: ThemeMode.light,
                      ),
                      Divider(height: 1),
                      RadioListTile<ThemeMode>(
                        title: Text('Tema Gelap'),
                        subtitle: Text('Nyaman untuk mata dalam kondisi minim cahaya'),
                        secondary: Icon(Icons.dark_mode_outlined),
                        value: ThemeMode.dark,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Penyimpanan Data
          const Text(
            'PENYIMPANAN DATA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              final txCount = state is TransactionLoaded ? state.transactions.length : 0;
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE0E7FF),
                        child: Icon(Icons.storage_outlined, color: Color(0xFF3730A3)),
                      ),
                      title: const Text('Database Lokal (SQLite)'),
                      subtitle: const Text('Semua transaksi tersimpan aman di perangkat lokal Anda'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Aktif',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFDCFCE7),
                        child: Icon(Icons.receipt_long_outlined, color: Color(0xFF166534)),
                      ),
                      title: const Text('Total Transaksi Tersimpan'),
                      subtitle: Text('$txCount transaksi tercatat'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFEF3C7),
                        child: Icon(Icons.tune_outlined, color: Color(0xFF92400E)),
                      ),
                      title: const Text('Shared Preferences'),
                      subtitle: const Text('Digunakan untuk menyimpan preferensi tema dan pengaturan'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Tentang Aplikasi
          const Text(
            'TENTANG MYUANG',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF1E3A8A),
                    child: Text('MU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text('MyUang - Manajemen Keuangan Pribadi'),
                  subtitle: Text('Versi 1.0.0+1 • Flutter & Clean Architecture'),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Aplikasi MyUang dirancang untuk membantu mahasiswa dan pengguna umum dalam mencatat pemasukan dan pengeluaran harian, memantau kondisi keuangan secara real-time, menganalisis statistik periode, serta mengekspor laporan keuangan dalam format PDF.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
