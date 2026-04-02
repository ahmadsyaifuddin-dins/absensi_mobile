import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/laporan_controller.dart';

class LaporanJarakView extends StatelessWidget {
  final LaporanController controller = Get.put(LaporanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Deteksi Jarak Absen", style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
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
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Filter Laporan PDF", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 15),

                  // 1. DROPDOWN KELAS
                  Text("Pilih Kelas", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 5),
                  Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedKelasId.value.isEmpty ? null : controller.selectedKelasId.value,
                    hint: Text("Pilih Kelas", style: GoogleFonts.poppins()),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      prefixIcon: Icon(Icons.class_, color: Colors.deepPurple),
                    ),
                    items: controller.listKelas.map<DropdownMenuItem<String>>((kelas) {
                      return DropdownMenuItem<String>(
                        value: kelas['id'].toString(),
                        child: Text(kelas['nama_kelas'], style: GoogleFonts.poppins()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      controller.selectedKelasId.value = val!;
                    },
                  )),
                  
                  SizedBox(height: 15),

                  // 2. PILIH TANGGAL
                  Text("Pilih Tanggal", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () => controller.chooseDateJarak(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.deepPurple),
                          SizedBox(width: 10),
                          Obx(() => Text(
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(controller.selectedDateJarak.value),
                            style: GoogleFonts.poppins(fontSize: 14),
                          )),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 25),

                  // 3. TOMBOL CETAK PDF
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.downloadPdfJarak(),
                      icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: Text("CETAK PDF LAPORAN", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
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
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.3))
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.deepPurple),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Laporan ini menggunakan perhitungan koordinat bumi (Haversine Formula) untuk mengkalkulasi jarak absensi siswa dari titik sekolah secara akurat.",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.deepPurple[800]),
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
}