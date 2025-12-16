import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/home_controller.dart';
// PASTIKAN IMPORT FILE VIEW YANG BENAR DI SINI
import '../views/absensi_view.dart';
import '../views/riwayat_view.dart'; // Buat file ini jika belum ada (dari chat sebelumnya)

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
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Obx(
                            () => Text(
                              controller.user['nama'] ?? "User",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize:
                                    18, // Agak dikecilin biar gak nabrak kalau nama panjang
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Obx(
                            () => Text(
                              "Siswa / ${controller.user['nisn_nip'] ?? '-'}", // Tampilkan NISN
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // --- CARD STATUS HARI INI (Versi Single: Cuma Masuk) ---
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Jadwal Masuk",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "07:30 WITA",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Divider(),
                        Text(
                          "Jangan lupa absen sebelum jam masuk!",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // --- MENU GRID ---
                  Text(
                    "Menu Utama",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                            final box = GetStorage();
                            String? token = box.read('token');
                            if (token != null) {
                              Get.to(() => AbsensiView(tokenUser: token));
                            } else {
                              Get.snackbar("Error", "Login dulu bos!");
                            }
                          },
                        ),

                        _buildMenuCard(
                          icon: Icons.history,
                          color: Colors.orange,
                          label: "Riwayat",
                          onTap: () {
                            Get.to(() => RiwayatView());
                          },
                        ),

                        _buildMenuCard(
                          icon: Icons.mail_outline,
                          color: Colors.green,
                          label: "Izin / Sakit",
                          onTap: () {
                            Get.snackbar("Info", "Fitur ini segera hadir!");
                          },
                        ),

                        _buildMenuCard(
                          icon: Icons.logout,
                          color: Colors.redAccent,
                          label: "Keluar",
                          onTap: () => controller.logout(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color color,
    required String label,
    required Function() onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
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
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
