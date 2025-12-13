import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/modules/login/views/login_view.dart';
import 'package:get_storage/get_storage.dart'; 
import 'app/modules/home/views/home_view.dart';
void main() async {
  await GetStorage.init(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    Widget initialRoute = box.hasData('token') ? HomeView() : LoginView();
    return GetMaterialApp(
      title: 'Absensi SMAN 3 Banjarmasin',
      debugShowCheckedModeBanner: false, // Biar label 'Debug' di pojok hilang
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        // Kita set warna biru sekolah biar konsisten sama LoginView
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: initialRoute, // 4. Ganti home statis jadi dinamis
    );
  }
}