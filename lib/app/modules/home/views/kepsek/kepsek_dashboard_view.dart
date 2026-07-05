import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';

// Import View yang bisa diakses Kepsek
import '../../../login/views/login_view.dart';
import '../guru/menu_laporan_view.dart'; // Kepsek bisa akses pusat laporan
import '../../../../data/providers/api_config.dart';

import 'grafik_persentase_view.dart';
import 'approval_kelas_view.dart'; 

class KepsekDashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    var user = box.read('user') ?? {'nama': 'Kepala Sekolah', 'nisn_nip': '-'};

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Header Background Hijau Tua (Emerald)
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.teal[800],
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
                        "Dashboard Eksekutif",
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout, color: Colors.white),
                        onPressed: () {
                          Get.defaultDialog(
                            title: "Logout",
                            middleText: "Keluar dari sistem Kepala Sekolah?",
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

                  // --- PROFIL KEPSEK ---
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: user['foto_profil'] != null
                            ? NetworkImage("${ApiConfig.imageUrl}${user['foto_profil']}") as ImageProvider
                            : null,
                        child: user['foto_profil'] == null
                            ? Icon(Icons.account_balance, size: 35, color: Colors.teal[800])
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
                            "Kepala Sekolah",
                            style: GoogleFonts.poppins(
                              color: Colors.teal[100],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 50),

                  // --- MENU PENGAWASAN ---
                  Text(
                    "Menu Pengawasan & Evaluasi",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900],
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
                      // 1. Persentase Kehadiran
                        _buildMenuCard(
                          icon: Icons.pie_chart,
                          label: "Persentase Kehadiran",
                          color: Colors.blue,
                          onTap: () {
                            // Arahkan ke View Grafik Khusus Kepsek
                            Get.to(() => GrafikPersentaseView());
                          },
                        ),
                      
                      // 2. Pusat Laporan (Harian/Bulanan)
                      _buildMenuCard(
                        icon: Icons.analytics,
                        label: "Pusat Laporan",
                        color: Colors.indigo,
                        onTap: () {
                          Get.to(() => MenuLaporanView());
                        },
                      ),
                      
                      // 3. Approval Kelas
                      _buildMenuCard(
                        icon: Icons.rule_folder,
                        label: "Approval Kelas",
                        color: Colors.orange,
                        onTap: () {
                          // Arahkan ke halaman Approval
                          Get.to(() => ApprovalKelasView());
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
            Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}