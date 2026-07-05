import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/laporan_controller.dart';

class LaporanMatpelView extends StatelessWidget {
  final LaporanController controller = Get.put(LaporanController());
  @override
  Widget build(BuildContext context) {
    // Panggil fetch jika list guru masih kosong
    if (controller.listGuruMatpel.isEmpty) {
      controller.fetchListGuruMatpel();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Laporan Presensi Matpel", style: GoogleFonts.poppins(fontSize: 18)),
        backgroundColor: Colors.cyan[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER INFO ---
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.cyan[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.cyan[200]!)
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.cyan[800]),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Laporan ini digunakan untuk mencetak perbandingan siswa yang hadir di gerbang vs hadir di kelas (Matpel).",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.cyan[900]),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 25),
            Text("Filter Laporan", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),

            // --- 1. FILTER KELAS ---
            Text("Pilih Kelas:", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
            SizedBox(height: 5),
            Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.selectedKelasId.value.isEmpty ? null : controller.selectedKelasId.value,
                  hint: Text("Pilih Kelas", style: GoogleFonts.poppins()),
                  items: controller.listKelas.map((kelas) {
                    return DropdownMenuItem<String>(
                      value: kelas['id'].toString(),
                      child: Text(kelas['nama_kelas'], style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.selectedKelasId.value = val;
                  },
                ),
              ),
            )),

            SizedBox(height: 20),

            // --- 2. FILTER GURU MATPEL ---
            Text("Pilih Guru Pengajar:", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
            SizedBox(height: 5),
            Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.selectedGuruMatpelId.value.isEmpty ? null : controller.selectedGuruMatpelId.value,
                  hint: Text("Pilih Guru", style: GoogleFonts.poppins()),
                  items: controller.listGuruMatpel.map((guru) {
                    return DropdownMenuItem<String>(
                      value: guru['id'].toString(),
                      child: Text("${guru['nama']} (NIP: ${guru['nip'] ?? '-'})", style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.selectedGuruMatpelId.value = val;
                  },
                ),
              ),
            )),

            SizedBox(height: 20),

            // --- 3. FILTER TANGGAL ---
            Text("Pilih Tanggal:", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
            SizedBox(height: 5),
            InkWell(
              onTap: () => controller.chooseDateMatpel(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(controller.selectedDateMatpel.value),
                      style: GoogleFonts.poppins(fontSize: 14),
                    )),
                    Icon(Icons.calendar_today, color: Colors.cyan[700], size: 20),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),

            // --- TOMBOL DOWNLOAD PDF ---
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => controller.downloadPdfMatpel(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
                icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text(
                  "DOWNLOAD PDF LAPORAN",
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}