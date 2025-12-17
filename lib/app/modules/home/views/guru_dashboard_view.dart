import 'package:absensi/app/modules/home/views/data_siswa_view.dart';
import 'package:absensi/app/modules/home/views/pengaturan_sekolah_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import '../../login/views/login_view.dart';
import '../controllers/guru_controller.dart';
import 'validasi_izin_view.dart';
import 'profile_view.dart';
import '../../../data/providers/api_config.dart';

class GuruDashboardView extends StatelessWidget {

  final GuruController controller = Get.put(GuruController());
  
  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    var user = box.read('user') ?? {'nama': 'Bapak/Ibu Guru', 'nisn_nip': '-'};

    return Scaffold(
      backgroundColor: Colors.grey[50], 
      body: Stack(
        children: [
          // HEADER BACKGROUND
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.indigo,
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
                        "Dashboard Guru",
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout, color: Colors.white),
                        onPressed: () {
                          Get.defaultDialog(
                            title: "Logout",
                            middleText: "Yakin ingin keluar?",
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

                  // --- PROFIL GURU (Klik Foto untuk Edit Profil) ---
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                           Get.to(() => ProfileView());
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: user['foto_profil'] != null 
                              ? NetworkImage("${ApiConfig.imageUrl}${user['foto_profil']}") as ImageProvider
                              : null,
                          child: user['foto_profil'] == null 
                              ? Icon(Icons.person, size: 35, color: Colors.indigo) 
                              : null,
                        ),
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
                            "NIP: ${user['nisn_nip'] ?? '-'}",
                            style: GoogleFonts.poppins(
                              color: Colors.indigo[100],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 30),
                  
                  // --- RINGKASAN HARI INI ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Ringkasan Hari Ini", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                      InkWell(
                        onTap: () => controller.refreshData(),
                        child: Icon(Icons.refresh, color: Colors.white70, size: 20),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  
                  Obx(() => Row(
                    children: [
                      _buildSummaryCard("Hadir", "${controller.stats['hadir']}", Colors.green),
                      SizedBox(width: 10),
                      _buildSummaryCard("Sakit/Izin", "${controller.stats['sakit']! + controller.stats['izin']!}", Colors.orange),
                      SizedBox(width: 10),
                      _buildSummaryCard("Belum", "${controller.stats['belum_absen']}", Colors.redAccent),
                    ],
                  )),

                  // --- MENU ADMINISTRASI ---
                  SizedBox(height: 30),
                  Text(
                    "Menu Administrasi",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  SizedBox(height: 15),

                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.3,
                    children: [
                      // 1. Validasi Izin
                      _buildMenuButton(
                        Icons.verified,
                        "Validasi Izin",
                        Colors.orange,
                        () {
                          Get.to(() => ValidasiIzinView());
                        },
                      ),
                      
                      // 2. Rekap Kelas
                      _buildMenuButton(
                        Icons.list_alt,
                        "Rekap Kelas",
                        Colors.blue,
                        () {},
                      ),

                      // 3. Data Siswa
                      _buildMenuButton(
                        Icons.people,
                        "Data Siswa",
                        Colors.purple,
                        () {
                           Get.to(() => DataSiswaView()); 
                        },
                      ),

                      // 4. Cetak Laporan
                      _buildMenuButton(
                        Icons.print,
                        "Cetak Laporan",
                        Colors.redAccent,
                        () {
                           // Nanti arahkan ke fitur Cetak
                        },
                      ),

                      _buildMenuButton(
                      Icons.settings,
                      "Lokasi Sekolah",
                      Colors.blueGrey,
                      () {
                        Get.to(() => PengaturanSekolahView());
                      },
                    ),
                    ],
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildSummaryCard(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
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
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}