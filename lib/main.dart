import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import View
import 'app/modules/login/views/login_view.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/modules/home/views/guru/guru_dashboard_view.dart';

void main() async {
  // 1. WAJIB: Pastikan binding flutter siap dulu
  WidgetsFlutterBinding.ensureInitialized();

  // 2. WAJIB: Initialize Storage (Siapkan hardisk kecil di browser)
  await GetStorage.init();

  // 3. WAJIB: Siapkan format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA ANTI-LUPA SAAT REFRESH ---
    final box = GetStorage();

    // Default-nya ke Login
    Widget initialRoute = LoginView();

    // Cek: Apakah ada token tersimpan?
    if (box.hasData('token')) {
      // Cek Role: Siswa atau Guru?
      String? role = box.read('role'); // Pastikan saat login kamu simpan 'role'

      print("Auto-Login terdeteksi. Role: $role"); // Cek di Console

      if (role == 'guru' || role == 'admin') {
        initialRoute = GuruDashboardView();
      } else {
        initialRoute = HomeView();
      }
    }
    // -------------------------------------

    return GetMaterialApp(
      title: 'Absensi SMAN 3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home:
          initialRoute,
    );
  }
}
