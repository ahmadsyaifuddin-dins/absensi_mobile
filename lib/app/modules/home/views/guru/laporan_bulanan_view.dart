import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/laporan_controller.dart';

class LaporanBulananView extends StatelessWidget {
  final controller = Get.put(LaporanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rekap Bulanan", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- FILTER AREA ---
          Container(
            padding: EdgeInsets.all(15),
            color: Colors.white,
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
                          labelText: "Bulan", border: OutlineInputBorder()
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
                        decoration: InputDecoration(labelText: "Tahun", border: OutlineInputBorder()),
                        items: [2024, 2025, 2026].map((y) => DropdownMenuItem(value: y, child: Text("$y"))).toList(),
                        onChanged: (val) => controller.selectedYear.value = val!,
                      )),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // DROPDOWN KELAS
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedKelasId.value.isEmpty ? null : controller.selectedKelasId.value,
                  hint: Text("Pilih Kelas"),
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  items: controller.listKelas.map<DropdownMenuItem<String>>((kelas) {
                    return DropdownMenuItem<String>(
                      value: kelas['id'].toString(),
                      child: Text(kelas['nama_kelas']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedKelasId.value = val!;
                    controller.fetchLaporanBulanan();
                  },
                )),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.fetchLaporanBulanan(),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        child: Text("CARI DATA", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => controller.downloadPdfBulanan(),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: Text("PDF", style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          ),
          
          // --- LIST DATA ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return Center(child: CircularProgressIndicator());
              if (controller.listBulanan.isEmpty) return Center(child: Text("Data tidak ditemukan"));

              return ListView.separated(
                itemCount: controller.listBulanan.length,
                separatorBuilder: (c, i) => Divider(),
                itemBuilder: (context, index) {
                  var item = controller.listBulanan[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal[100],
                      child: Text("${index + 1}"),
                    ),
                    title: Text(item['nama'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [
                        _badge("Hadir: ${item['hadir']}", Colors.green),
                        SizedBox(width: 5),
                        _badge("Sakit: ${item['sakit']}", Colors.orange),
                        SizedBox(width: 5),
                        _badge("Izin: ${item['izin']}", Colors.blue),
                        SizedBox(width: 5),
                         // Alpa opsional kalau mau ditampilkan
                         // _badge("A: ${item['alpa']}", Colors.red),
                      ],
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

  Widget _badge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  String _namaBulan(int index) {
    const months = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
    return months[index - 1];
  }
}