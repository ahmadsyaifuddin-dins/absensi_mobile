import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/matpel_controller.dart';

class AbsensiMatpelView extends StatelessWidget {
  final MatpelController controller = Get.put(MatpelController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Presensi Mata Pelajaran", style: GoogleFonts.poppins()),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Pilih Guru Mata Pelajaran",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Pastikan kamu sedang berada di dalam kelas yang bersangkutan.",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: 25),

            // --- DROPDOWN GURU ---
            Obx(() {
              if (controller.isLoading.value && controller.listGuru.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.listGuru.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red[200]!)
                  ),
                  child: Text(
                    "Belum ada data guru terdaftar.",
                    style: GoogleFonts.poppins(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    hint: Text("Pilih Guru...", style: GoogleFonts.poppins()),
                    value: controller.selectedGuruId.value,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.blueAccent),
                    items: controller.listGuru.map((guru) {
                      return DropdownMenuItem<int>(
                        value: guru['id'],
                        child: Text(
                          "${guru['nama']} (NIP: ${guru['nip'] ?? '-'})",
                          style: GoogleFonts.poppins(),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      controller.selectedGuruId.value = val;
                    },
                  ),
                ),
              );
            }),

            SizedBox(height: 40),

            // --- TOMBOL ABSEN ---
            Obx(() => SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value || controller.selectedGuruId.value == null
                    ? null
                    : () => controller.submitAbsenMatpel(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: controller.isLoading.value && controller.listGuru.isNotEmpty
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "HADIR DI KELAS",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}