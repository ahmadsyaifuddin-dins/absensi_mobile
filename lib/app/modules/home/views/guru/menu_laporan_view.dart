import 'package:absensi/app/modules/home/views/guru/laporan_rekap_izin_view.dart';
import 'package:absensi/app/modules/home/views/guru/laporan_telat_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Import View Laporan yang sudah kita buat
import 'laporan_harian_view.dart';
import 'laporan_bulanan_view.dart';
import 'laporan_siswa_view.dart';
import 'validasi_izin_view.dart'; // Kita masukkan sini juga biar ngumpul

class MenuLaporanView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pusat Laporan", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal[800], // Warna agak gelap biar beda dikit
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text(
            "Silakan pilih jenis laporan yang ingin dicetak atau dilihat:",
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
          SizedBox(height: 20),

          // 1. LAPORAN HARIAN
          _buildMenuItem(
            title: "Laporan Harian",
            subtitle: "Cek kehadiran per hari & per kelas",
            icon: Icons.today,
            color: Colors.teal,
            onTap: () => Get.to(() => LaporanHarianView()),
          ),

          // 2. LAPORAN BULANAN
          _buildMenuItem(
            title: "Rekap Bulanan",
            subtitle: "Total kehadiran siswa dalam sebulan",
            icon: Icons.calendar_month,
            color: Colors.orange,
            onTap: () => Get.to(() => LaporanBulananView()),
          ),

          // 3. DETAIL SISWA
          _buildMenuItem(
            title: "Track Record Siswa",
            subtitle: "Riwayat lengkap satu siswa",
            icon: Icons.person_search,
            color: Colors.indigo,
            onTap: () => Get.to(() => LaporanSiswaView()),
          ),

          // 4. PENGAJUAN IZIN (Validasi)
          // Kalau mau dijadikan arsip laporan
          _buildMenuItem(
            title: "Rekap Data Izin", // Ganti judul biar lebih relevan
            subtitle: "Laporan sakit & izin bulanan",
            icon: Icons.history_edu, // Ganti icon biar beda sama validasi
            color: Colors.blue,
            // Arahkan ke View Laporan Baru
            onTap: () => Get.to(() => LaporanRekapIzinView()), 
          ),

          // 5. LAPORAN KETERLAMBATAN (Top Skor Telat)
          // Nanti kita buat view-nya
          _buildMenuItem(
            title: "Ranking Keterlambatan",
            subtitle: "Daftar siswa paling sering telat",
            icon: Icons.timer_off,
            color: Colors.redAccent,
            onTap: () {
              Get.to(() => LaporanTelatView());
              // Get.snackbar("Info", "Fitur ini akan segera hadir!");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}