import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_controller.dart';
import '../views/absensi_view.dart';
import 'package:get_storage/get_storage.dart';

class HomeView extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // 1. BACKGROUND HEADER BIRU
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueAccent, Colors.blue[700]!],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // 2. KONTEN UTAMA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  
                  // --- HEADER INFO USER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Halo, Selamat Pagi 👋",
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                          ),
                          Obx(() => Text(
                            controller.user['nama'] ?? "User", // Ambil nama dinamis
                            style: GoogleFonts.poppins(
                              color: Colors.white, 
                              fontSize: 20, 
                              fontWeight: FontWeight.bold
                            ),
                          )),
                          Obx(() => Text(
                            controller.user['role'] == 'siswa' 
                                ? "Siswa XII MIPA 1" // Nanti kita ambil dari relasi kelas
                                : "Guru / Staff",
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                          )),
                        ],
                      ),
                      // Avatar/Foto Profil
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      )
                    ],
                  ),

                  SizedBox(height: 30),

                  // --- CARD STATUS HARI INI ---
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusItem("Masuk", "--:--"),
                        Container(height: 40, width: 1, color: Colors.grey[300]),
                        _buildStatusItem("Pulang", "--:--"),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // --- MENU GRID ---
                  Text("Menu Utama", 
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        _buildMenuCard(
                          icon: Icons.fingerprint, 
                          color: Colors.blueAccent, 
                          label: "Absen Masuk",
                          onTap: () {
                             // Ambil token asli dari storage
                             final box = GetStorage();
                             String? token = box.read('token');
                             
                             if (token != null) {
                               Get.to(() => AbsensiView(tokenUser: token));
                             } else {
                               Get.snackbar("Error", "Token tidak ditemukan, silakan login ulang");
                             }
                          }
                        ),
                        _buildMenuCard(
                          icon: Icons.history, 
                          color: Colors.orange, 
                          label: "Riwayat",
                          onTap: () {}
                        ),
                        _buildMenuCard(
                          icon: Icons.mail_outline, 
                          color: Colors.green, 
                          label: "Izin / Sakit",
                          onTap: () {}
                        ),
                         _buildMenuCard(
                          icon: Icons.logout, 
                          color: Colors.redAccent, 
                          label: "Keluar",
                          onTap: () => controller.logout(), // Panggil fungsi logout
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper biar kodingan rapi
  Widget _buildStatusItem(String label, String time) {
    return Column(
      children: [
        Text(time, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.poppins(color: Colors.grey)),
      ],
    );
  }

  Widget _buildMenuCard({required IconData icon, required Color color, required String label, required Function() onTap}) {
    return Material(
      color: Colors.white, // Warna background pindah ke Material
      borderRadius: BorderRadius.circular(15),
      elevation: 2, // Kasih bayangan dikit biar timbul
      child: InkWell(
        borderRadius: BorderRadius.circular(15), // Biar efek pencetnya bulat ngikutin border
        onTap: onTap, // Fungsi onTap pindah ke sini
        child: Container(
          // HAPUS decoration color disini biar transparan
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(height: 10),
              Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}