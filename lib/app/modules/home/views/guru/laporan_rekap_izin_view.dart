import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Jangan lupa ini
import '../../controllers/laporan_controller.dart';
import '../detail_foto_view.dart';
import '../../../../data/providers/api_config.dart';

class LaporanRekapIzinView extends StatelessWidget {
  final controller = Get.put(LaporanController());

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id_ID', null);
    
    // Panggil fetch saat pertama dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchRekapIzin();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Rekap Izin & Sakit", style: GoogleFonts.poppins()),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => controller.downloadPdfRekapIzin(),
            tooltip: "Download PDF",
          )
        ],
      ),
      body: Column(
        children: [
          // --- SECTION FILTER ---
          Container(
            padding: EdgeInsets.all(15),
            color: Colors.white,
            child: Column(
              children: [
                // Row 1: Bulan & Tahun
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<int>(
                        value: controller.selectedMonth.value,
                        isExpanded: true, // 1. Wajib true
                        items: List.generate(12, (index) => index + 1)
                            .map((m) => DropdownMenuItem(
                                value: m, 
                                // 2. SOLUSI UTAMA: Bungkus teks bulan dgn FittedBox
                                // Jadi kalau teks "September" kepanjangan, dia akan mengecilkan font otomatis
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft, // Rata kiri
                                  child: Text(DateFormat('MMMM', 'id_ID').format(DateTime(2022, m, 1)))
                                )
                            )).toList(),
                        onChanged: (val) {
                          controller.selectedMonth.value = val!;
                          controller.fetchRekapIzin();
                        },
                        decoration: InputDecoration(
                          labelText: "Bulan", 
                          border: OutlineInputBorder(), 
                          // 3. Padding dikecilkan
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0)
                        ),
                      )),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<int>(
                        value: controller.selectedYear.value,
                        items: [2024, 2025, 2026].map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                        onChanged: (val) {
                          controller.selectedYear.value = val!;
                          controller.fetchRekapIzin();
                        },
                        decoration: InputDecoration(labelText: "Tahun", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                      )),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                
                // Row 2: Filter Kelas & Kategori
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedKategoriIzin.value,
                        items: ['Semua', 'Sakit', 'Izin'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) {
                          controller.selectedKategoriIzin.value = val!;
                          controller.fetchRekapIzin();
                        },
                        decoration: InputDecoration(labelText: "Kategori", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- SECTION LIST DATA ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return Center(child: CircularProgressIndicator());
              if (controller.listRekapIzin.isEmpty) return Center(child: Text("Tidak ada data izin bulan ini."));

              return ListView.builder(
                padding: EdgeInsets.all(15),
                itemCount: controller.listRekapIzin.length,
                itemBuilder: (context, index) {
                  var item = controller.listRekapIzin[index];
                  var user = item['user'] ?? {'nama': 'Siswa'};
                  var kelas = user['kelas'] ?? {'nama_kelas': '-'};
                  bool isSakit = item['status'] == 'Sakit';

                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      leading: GestureDetector(
                        onTap: () {
                           if (item['bukti_izin'] != null) {
                             Get.to(() => DetailFotoView(imageUrl: "${ApiConfig.imageUrl}${item['bukti_izin']}"));
                           }
                        },
                        child: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: isSakit ? Colors.red[100] : Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                            image: item['bukti_izin'] != null ? DecorationImage(
                              image: NetworkImage("${ApiConfig.imageUrl}${item['bukti_izin']}"),
                              fit: BoxFit.cover
                            ) : null,
                          ),
                          child: item['bukti_izin'] == null 
                            ? Icon(isSakit ? Icons.local_hospital : Icons.assignment, color: isSakit ? Colors.red : Colors.blue)
                            : null,
                        ),
                      ),
                      title: Text(user['nama'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // DISINI KITA PANGGIL HELPER BARU
                          Text(
                            "${kelas['nama_kelas']} • ${_formatDate(item['tanggal'])}", 
                             style: TextStyle(color: Colors.black87)
                          ),
                          SizedBox(height: 5),
                          Text("Alasan: ${item['catatan']}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
                        ],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSakit ? Colors.red : Colors.blue,
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: Text(item['status'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Helper Format Tanggal (Clean Version)
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    
    try {
      // 1. Ambil 10 karakter pertama (YYYY-MM-DD)
      String rawDate = dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr;

      // 2. Pecah & Rakit Manual (Safety agar tidak terpengaruh jam/timezone)
      List<String> parts = rawDate.split('-');
      if (parts.length == 3) {
        DateTime dt = DateTime(
          int.parse(parts[0]), // Tahun
          int.parse(parts[1]), // Bulan
          int.parse(parts[2])  // Hari
        );
        return DateFormat('d MMMM yyyy', 'id_ID').format(dt);
      }
      
      // Fallback jika format tidak standar
      return DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.parse(dateStr));
      
    } catch (e) {
      return dateStr; // Jika error parsing, kembalikan string aslinya
    }
  }
}