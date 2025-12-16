import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import Views
import 'app/modules/login/views/login_view.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/modules/home/views/guru_dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    // --- LOGIKA AUTO LOGIN PINTAR ---
    Widget initialRoute = LoginView(); // Default

    if (box.hasData('token')) {
      String? role = box.read('role'); // Baca role yg disimpan pas login

      if (role == 'guru' || role == 'admin') {
        initialRoute = GuruDashboardView();
      } else {
        initialRoute = HomeView();
      }
    }
    // --------------------------------

    return GetMaterialApp(
      title: 'Absensi SMAN 3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: initialRoute,
    );
  }
}
