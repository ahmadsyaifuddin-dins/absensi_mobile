import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../controllers/laporan_controller.dart';

class LaporanSiswaView extends StatelessWidget {
  final controller = Get.put(LaporanController());

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id_ID', null);

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Absensi Siswa", style: GoogleFonts.poppins()),
        backgroundColor: Colors.indigo,
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
                // 1. DROPDOWN KELAS
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedKelasId.value.isEmpty ? null : controller.selectedKelasId.value,
                  hint: Text("Pilih Kelas"),
                  decoration: InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10)),
                  items: controller.listKelas.map<DropdownMenuItem<String>>((kelas) {
                    return DropdownMenuItem<String>(
                      value: kelas['id'].toString(),
                      child: Text(kelas['nama_kelas']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedKelasId.value = val!;
                    controller.fetchSiswaByKelas(); // Load Siswa
                  },
                )),
                SizedBox(height: 10),
                
                // 2. DROPDOWN SISWA (Muncul setelah pilih kelas)
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedSiswaId.value.isEmpty || !controller.listSiswaDropdown.any((e) => e['id'].toString() == controller.selectedSiswaId.value) 
                      ? null 
                      : controller.selectedSiswaId.value,
                  hint: Text("Pilih Siswa"),
                  decoration: InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10)),
                  items: controller.listSiswaDropdown.map<DropdownMenuItem<String>>((siswa) {
                    return DropdownMenuItem<String>(
                      value: siswa['id'].toString(),
                      child: Text(siswa['nama']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedSiswaId.value = val!;
                  },
                )),

                SizedBox(height: 10),
                
                // 3. BULAN & TAHUN (Untuk Filter PDF)
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<int>(
                        value: controller.selectedMonth.value,
                        decoration: InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10)),
                        items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text(_namaBulan(index + 1)))),
                        onChanged: (val) => controller.selectedMonth.value = val!,
                      )),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<int>(
                        value: controller.selectedYear.value,
                        decoration: InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10)),
                        items: [2024, 2025, 2026].map((y) => DropdownMenuItem(value: y, child: Text("$y"))).toList(),
                        onChanged: (val) => controller.selectedYear.value = val!,
                      )),
                    ),
                  ],
                ),

                SizedBox(height: 15),

                // TOMBOL
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.fetchLaporanSiswa(),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                        child: Text("LIHAT DATA", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => controller.downloadPdfSiswa(),
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
              if (controller.listDetailSiswa.isEmpty) return Center(child: Text("Silakan pilih siswa dan klik Lihat Data"));

              return ListView.separated(
                itemCount: controller.listDetailSiswa.length,
                separatorBuilder: (c, i) => Divider(),
                itemBuilder: (context, index) {
                  var item = controller.listDetailSiswa[index];
                  return ListTile(
                    title: Text(_formatDate(item['tanggal']), style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Masuk: ${item['jam_masuk'] ?? '-'}"),
                        if (item['status'] != 'Hadir') 
                          Text("Ket: ${item['status']} (${item['catatan'] ?? '-'})", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getColor(item['status']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(item['status'], style: TextStyle(color: _getColor(item['status']), fontWeight: FontWeight.bold)),
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

  Color _getColor(String status) {
    if (status == 'Hadir') return Colors.green;
    if (status == 'Sakit') return Colors.orange;
    if (status == 'Izin') return Colors.blue;
    return Colors.red;
  }

  String _namaBulan(int index) {
    const months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];
    return months[index - 1];
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('EEEE, d MMMM y', 'id_ID').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}