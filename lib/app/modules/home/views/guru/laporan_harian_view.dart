import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../controllers/laporan_controller.dart';
import '../../../../data/providers/api_config.dart';

class LaporanHarianView extends StatelessWidget {
  final controller = Get.put(LaporanController());

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id_ID', null);

    return Scaffold(
      appBar: AppBar(
        title: Text("Laporan Harian", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- BAGIAN FILTER (TANGGAL & KELAS) ---
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))]
            ),
            child: Column(
              children: [
                // 1. DATE PICKER
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                          DateFormat('EEEE, d MMMM y', 'id_ID').format(controller.selectedDate.value),
                          style: GoogleFonts.poppins(fontSize: 16),
                        )),
                        Icon(Icons.calendar_today, color: Colors.teal),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // 2. DROPDOWN KELAS
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedKelasId.value.isEmpty ? null : controller.selectedKelasId.value,
                  hint: Text("Pilih Kelas"),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)
                  ),
                  items: controller.listKelas.map<DropdownMenuItem<String>>((kelas) {
                    return DropdownMenuItem<String>(
                      value: kelas['id'].toString(),
                      child: Text(kelas['nama_kelas']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedKelasId.value = val!;
                    // Otomatis refresh data pas ganti kelas
                    controller.fetchLaporanHarian(); 
                  },
                )),

                SizedBox(height: 10),

                Row(
                  children: [
                    // TOMBOL CARI
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => controller.fetchLaporanHarian(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal, 
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12)
                        ),
                        child: Text("TAMPILKAN", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 10),
                    
                    // TOMBOL PDF
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.downloadPdf(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent, 
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12)
                        ),
                        icon: Icon(Icons.picture_as_pdf),
                        label: Text("PDF"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- BAGIAN LIST SISWA ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return Center(child: CircularProgressIndicator());
              
              if (controller.listHarian.isEmpty) {
                return Center(child: Text("Silakan pilih filter dan klik Tampilkan"));
              }

              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: controller.listHarian.length,
                itemBuilder: (context, index) {
                  var item = controller.listHarian[index];
                  String status = item['status'];
                  
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: item['foto_profil'] != null 
                            ? NetworkImage("${ApiConfig.imageUrl}${item['foto_profil']}") 
                            : null,
                        child: item['foto_profil'] == null 
                            ? Text(item['nama'][0], style: TextStyle(fontWeight: FontWeight.bold)) 
                            : null,
                      ),
                      title: Text(item['nama'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      subtitle: Text("NISN: ${item['nisn']}", style: GoogleFonts.poppins(fontSize: 12)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: Text(
                              status, 
                              style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12)
                            ),
                          ),
                          SizedBox(height: 4),
                          if (status == 'Hadir')
                            Text(
                              "${item['jam_masuk']} ${item['terlambat'] == true || item['terlambat'] == 1 ? '(Telat)' : ''}",
                              style: TextStyle(fontSize: 10, color: item['terlambat'] == true || item['terlambat'] == 1 ? Colors.red : Colors.grey)
                            )
                        ],
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

  Color _getStatusColor(String status) {
    if (status == 'Hadir') return Colors.green;
    if (status == 'Izin') return Colors.blue;
    if (status == 'Sakit') return Colors.orange;
    if (status == 'Alpa' || status == 'Belum Absen') return Colors.red;
    return Colors.grey;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != controller.selectedDate.value) {
      controller.selectedDate.value = picked;
      // Otomatis refresh pas ganti tanggal
      controller.fetchLaporanHarian();
    }
  }
}