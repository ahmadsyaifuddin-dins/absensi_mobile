import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import '../guru/laporan_telat_view.dart';
import '../guru/laporan_redflag_view.dart';

// Import View
import '../../../login/views/login_view.dart';
import '../guru/data_siswa_view.dart'; // BK bisa cari data siswa
import '../../../../data/providers/api_config.dart';

class GuruBkDashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    var user = box.read('user') ?? {'nama': 'Guru BK', 'nisn_nip': '-'};

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Header Background Cokelat / Deep Orange
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.brown[600],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TOP BAR (LOGOUT) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Dashboard Bimbingan Konseling",
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout, color: Colors.white),
                        onPressed: () {
                          Get.defaultDialog(
                            title: "Logout",
                            middleText: "Keluar dari sistem BK?",
                            textConfirm: "Ya",
                            textCancel: "Batal",
                            confirmTextColor: Colors.white,
                            onConfirm: () {
                              box.erase();
                              Get.offAll(() => LoginView());
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  // --- PROFIL GURU BK ---
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: user['foto_profil'] != null
                            ? NetworkImage("${ApiConfig.imageUrl}${user['foto_profil']}") as ImageProvider
                            : null,
                        child: user['foto_profil'] == null
                            ? Icon(Icons.support_agent, size: 35, color: Colors.brown[600])
                            : null,
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['nama'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Guru BK",
                            style: GoogleFonts.poppins(
                              color: Colors.brown[100],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 50),

                  // --- MENU TINDAKAN KEDISIPLINAN ---
                  Text(
                    "Tindakan Kedisiplinan",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                  SizedBox(height: 15),

                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      // 1. Top Skor Keterlambatan
                      _buildMenuCard(
                        icon: Icons.timer_off,
                        label: "Rekap Keterlambatan",
                        color: Colors.redAccent,
                        onTap: () {
                          // Arahkan ke View Laporan Telat
                          Get.to(() => LaporanTelatView());
                        },
                      ),
                      
                      // 2. Siswa Bermasalah (Red Flag Alpa/Bolos)
                      _buildMenuCard(
                        icon: Icons.flag,
                        label: "Siswa Bermasalah (Red Flag)",
                        color: Colors.red,
                        onTap: () {
                          // Arahkan ke View Laporan Red Flag
                          Get.to(() => LaporanRedflagView());
                        },
                      ),
                      
                      // 3. Track Record Individu (Cari nama anak)
                      _buildMenuCard(
                        icon: Icons.person_search,
                        label: "Track Record Individu",
                        color: Colors.teal,
                        onTap: () {
                          Get.to(() => DataSiswaView()); 
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}