import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/laporan_controller.dart';

class LaporanTelatView extends StatelessWidget {
  final controller = Get.put(LaporanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ranking Keterlambatan", style: GoogleFonts.poppins()),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // --- 1. FILTER AREA (Bulan & Tahun) ---
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))
              ]
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // DROPDOWN BULAN
                    Expanded(
                      flex: 2,
                      child: Obx(() => DropdownButtonFormField<int>(
                        value: controller.selectedMonth.value,
                        decoration: InputDecoration(
                          labelText: "Bulan", 
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                        ),
                        items: List.generate(12, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text(_namaBulan(index + 1)),
                          );
                        }),
                        onChanged: (val) => controller.selectedMonth.value = val!,
                      )),
                    ),
                    SizedBox(width: 10),
                    // DROPDOWN TAHUN
                    Expanded(
                      flex: 1,
                      child: Obx(() => DropdownButtonFormField<int>(
                        value: controller.selectedYear.value,
                        decoration: InputDecoration(
                          labelText: "Tahun", 
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                        ),
                        items: [2024, 2025, 2026].map((y) => DropdownMenuItem(value: y, child: Text("$y"))).toList(),
                        onChanged: (val) => controller.selectedYear.value = val!,
                      )),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // TOMBOL AKSI
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.fetchRekapTelat(),
                        icon: Icon(Icons.search, size: 18),
                        label: Text("TAMPILKAN DATA"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent, 
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12)
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => controller.downloadPdfTelat(),
                      child: Icon(Icons.picture_as_pdf),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800], 
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12)
                      ),
                    )
                  ],
                )
              ],
            ),
          ),

          // --- 2. LIST DATA (RANKING) ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: Colors.redAccent));
              }

              if (controller.listTelat.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("Tidak ada siswa terlambat bulan ini.", style: GoogleFonts.poppins(color: Colors.grey)),
                      Text("Pertahankan!", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(15),
                itemCount: controller.listTelat.length,
                itemBuilder: (context, index) {
                  var item = controller.listTelat[index];
                  
                  // WARNA MEDALI
                  Color badgeColor;
                  Color textColor = Colors.white;
                  double scale = 1.0;

                  if (index == 0) {
                    badgeColor = Color(0xFFFFD700); // Emas
                    scale = 1.2;
                  } else if (index == 1) {
                    badgeColor = Color(0xFFC0C0C0); // Perak
                    scale = 1.1;
                  } else if (index == 2) {
                    badgeColor = Color(0xFFCD7F32); // Perunggu
                  } else {
                    badgeColor = Colors.grey[300]!;
                    textColor = Colors.black54;
                  }

                  return Transform.scale(
                    scale: index == 0 ? 1.02 : 1.0, // Efek zoom dikit buat juara 1
                    child: Card(
                      elevation: index < 3 ? 4 : 1,
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          // NOMOR URUT / RANKING
                          leading: CircleAvatar(
                            backgroundColor: badgeColor,
                            radius: 20 * scale,
                            child: Text(
                              "#${index + 1}", 
                              style: GoogleFonts.poppins(
                                color: textColor, 
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * scale
                              )
                            ),
                          ),
                          
                          // NAMA & KELAS
                          title: Text(
                            item['nama'], 
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                          subtitle: Text(
                            "${item['nama_kelas']}",
                            style: GoogleFonts.poppins(color: Colors.grey[600])
                          ),
                          
                          // STATISTIK TELAT
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${item['total_menit']} Menit", 
                                style: GoogleFonts.poppins(
                                  color: Colors.red[700], 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 14
                                )
                              ),
                              Text(
                                "${item['total_kali_telat']}x Telat",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }

  // Helper Nama Bulan
  String _namaBulan(int index) {
    const months = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
    return months[index - 1];
  }
}