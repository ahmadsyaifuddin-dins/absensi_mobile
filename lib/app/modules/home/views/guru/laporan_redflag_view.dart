import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/laporan_controller.dart';

class LaporanRedflagView extends StatelessWidget {
  // Pakai Get.put biar nggak error "not found" kayak tadi
  final LaporanController controller = Get.put(LaporanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Red Flag / Siswa Bermasalah", style: GoogleFonts.poppins(fontSize: 18)),
        backgroundColor: Colors.red[800], // Warna merah gelap biar berasa "Red Flag"
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KARTU FILTER ---
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Filter Periode Laporan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 15),

                  // DROPDOWN BULAN & TAHUN
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Bulan", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                            SizedBox(height: 5),
                            Obx(() => DropdownButtonFormField<int>(
                              value: controller.selectedMonth.value,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                              items: List.generate(12, (index) {
                                return DropdownMenuItem(
                                  value: index + 1, 
                                  child: Text(_namaBulan(index + 1), style: GoogleFonts.poppins())
                                );
                              }),
                              onChanged: (val) => controller.selectedMonth.value = val!,
                            )),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tahun", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                            SizedBox(height: 5),
                            Obx(() => DropdownButtonFormField<int>(
                              value: controller.selectedYear.value,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                              items: [2024, 2025, 2026, 2027].map((y) {
                                return DropdownMenuItem(value: y, child: Text("$y", style: GoogleFonts.poppins()));
                              }).toList(),
                              onChanged: (val) => controller.selectedYear.value = val!,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 25),

                  // TOMBOL CETAK PDF
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.downloadPdfRedFlag(),
                      icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
                      label: Text("CETAK PDF RED FLAG", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // --- INFO BOX ---
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.3))
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.red[800]),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bagaimana Poin Dihitung?",
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red[800]),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Sistem otomatis menghitung poin pelanggaran siswa dalam satu bulan dengan bobot:\n• Alpa = 3 Poin\n• Sakit/Izin = 1 Poin\n• Terlambat = 1 Poin\n\nSiswa dengan poin terbanyak akan berada di urutan paling atas.",
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.red[900]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper untuk nama bulan
  String _namaBulan(int index) {
    const months = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
    return months[index - 1];
  }
}