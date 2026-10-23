# MyUang — Aplikasi Manajemen Keuangan

MyUang merupakan aplikasi mobile berbasis Flutter yang dirancang untuk membantu pengguna mencatat dan memantau pemasukan serta pengeluaran secara praktis.

## Fitur Utama

- **Dashboard:** Menampilkan ringkasan saldo, pemasukan, dan pengeluaran.
- **Manajemen Transaksi:** Menambahkan, mengubah, dan menghapus transaksi keuangan.
- **Statistik Keuangan:** Menampilkan ringkasan dan grafik keuangan berdasarkan periode.
- **Pengaturan Tema:** Mendukung tema terang, gelap, dan mengikuti sistem.
- **Ekspor PDF:** Membuat laporan keuangan dalam format PDF.

## Teknologi yang Digunakan

- Flutter
- Dart
- BLoC untuk state management
- Clean Architecture
- SQLite untuk penyimpanan transaksi lokal
- Shared Preferences untuk menyimpan preferensi tema
- fl_chart untuk visualisasi data
- pdf dan printing untuk pembuatan serta penampilan laporan PDF

## Struktur Proyek

```text
lib/
├── core/
├── data/
├── domain/
└── presentation/
```

Struktur tersebut memisahkan fungsi umum, pengelolaan data, logika bisnis, dan tampilan aplikasi.

## Cara Menjalankan Proyek

1. Pastikan Flutter SDK dan Git sudah terpasang.
2. Clone repository:

   `git clone https://github.com/vanyanyssa/MyUang.git`

3. Masuk ke folder proyek:

   `cd MyUang`

4. Unduh dependensi:

   `flutter pub get`

5. Jalankan aplikasi pada perangkat atau emulator yang tersedia:

   `flutter run`

## Pengembang

**Vanya Nyssa Maulida**  
Program Studi Teknik Informatika  
UIN Maulana Malik Ibrahim Malang

## Status Proyek

Proyek pengembangan aplikasi mobile untuk keperluan akademik.
