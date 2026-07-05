import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';

// Import View
import '../../../login/views/login_view.dart';
import 'hari_libur_view.dart';
import 'manajemen_guru_view.dart';
import '../guru/data_siswa_view.dart';
import '../guru/rekap_kelas_view.dart';
import '../guru/pengaturan_sekolah_view.dart';
import '../guru/menu_laporan_view.dart';

class AdminDashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    var user = box.read('user') ?? {'nama': 'Administrator Tata Usaha'};

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Header Background Merah
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.red[800],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tata Usaha Panel", style: GoogleFonts.poppins(color: Colors.white70)),
                      IconButton(
                        icon: Icon(Icons.logout, color: Colors.white),
                        onPressed: () {
                           Get.defaultDialog(
                            title: "Logout",
                            middleText: "Keluar dari sistem Tata Usaha?",
                            textConfirm: "Ya", textCancel: "Batal",
                            confirmTextColor: Colors.white,
                            onConfirm: () {
                              box.erase();
                              Get.offAll(() => LoginView());
                            }
                           );
                        },
                      )
                    ],
                  ),
                  
                  SizedBox(height: 10),
                  
                  // --- INFO USER ---
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.admin_panel_settings, size: 35, color: Colors.red[800]),
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['nama'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Tata Usaha Sekolah", style: GoogleFonts.poppins(color: Colors.red[100])),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 50),

                  // --- MENU GRID ADMINISTRASI ---
                  Text("Manajemen Master Data", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 15),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      _buildMenuCard(
                        icon: Icons.supervisor_account,
                        label: "Data Guru",
                        color: Colors.orange,
                        onTap: () => Get.to(() => ManajemenGuruView()),
                      ),
                      _buildMenuCard(
                        icon: Icons.people,
                        label: "Data Siswa",
                        color: Colors.purple,
                        onTap: () => Get.to(() => DataSiswaView()),
                      ),
                      _buildMenuCard(
                        icon: Icons.meeting_room,
                        label: "Manajemen Kelas",
                        color: Colors.teal,
                        onTap: () => Get.to(() => RekapKelasView()),
                      ),
                      _buildMenuCard(
                        icon: Icons.event_busy,
                        label: "Hari Libur",
                        color: Colors.pink,    
                        onTap: () => Get.to(() => HariLiburView()),
                      ),
                      _buildMenuCard(
                        icon: Icons.settings,
                        label: "Pengaturan Sekolah",
                        color: Colors.blueGrey,
                        onTap: () => Get.to(() => PengaturanSekolahView()),
                      ),
                      _buildMenuCard(
                        icon: Icons.analytics,
                        label: "Pusat Laporan",
                        color: Colors.blue,
                        onTap: () => Get.to(() => MenuLaporanView()),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
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