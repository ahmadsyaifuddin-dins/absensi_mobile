import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends StatelessWidget {
  // Panggil Controller-nya
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //  (GANTI ICON JADI IMAGE)
              // Icon(Icons.school_rounded, size: 80, color: Colors.blueAccent),
              
              // Menampilkan Logo Sekolah
              Container(
                height: 120, // Atur tinggi logo sesuai kebutuhan
                child: Image.asset(
                  'assets/images/logo.png', 
                  fit: BoxFit.contain, // Agar gambar tidak terpotong
                ),
              ),

              SizedBox(height: 16),
              
              Obx(() => Text(
                controller.namaSekolah.value.toUpperCase(), 
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              )),
              Text(
                "Silakan login untuk melanjutkan",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              SizedBox(height: 40),

              // 2. INPUT NISN / NIP
              TextField(
                controller: controller.idC,
                decoration: InputDecoration(
                  labelText: "NISN / NIP", 
                  hintText: "Masukkan NISN (Siswa) atau NIP (Guru)",
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 16),

              // 3. INPUT PASSWORD
              TextField(
                controller: controller.passC,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 24),

              // 4. TOMBOL LOGIN (Dengan Loading State)
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value 
                  ? null 
                  : () => controller.login(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("MASUK", 
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              )),
              
              SizedBox(height: 20),
              Text(
                "Lupa password? Hubungi Guru ya!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}