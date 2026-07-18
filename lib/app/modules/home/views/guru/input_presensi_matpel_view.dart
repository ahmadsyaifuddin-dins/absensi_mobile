import 'package:absensi/app/modules/home/views/guru/riwayat_matpel_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/input_presensi_controller.dart';
import '../../../../data/providers/api_config.dart';

class InputPresensiMatpelView extends StatelessWidget {
  final controller = Get.put(InputPresensiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mulai Presensi Kelas", style: GoogleFonts.poppins()),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            tooltip: 'Riwayat Presensi',
            onPressed: () {
              // Arahkan ke halaman riwayat
              Get.to(() => RiwayatMatpelView());
            },
          )
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // --- KARTU INPUT KELAS & MATPEL ---
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pilih Kelas", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
                SizedBox(height: 5),
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedKelasId.value.isEmpty ? null : controller.selectedKelasId.value,
                  hint: Text("Pilih Kelas yang diajar", style: GoogleFonts.poppins()),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                  items: controller.listKelas.map<DropdownMenuItem<String>>((kelas) {
                    return DropdownMenuItem<String>(
                      value: kelas['id'].toString(),
                      child: Text(kelas['nama_kelas'], style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedKelasId.value = val;
                      controller.fetchSiswaByKelas(val); // Load data siswa otomatis
                    }
                  },
                )),
                
                SizedBox(height: 15),
                
                Text("Mata Pelajaran", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
                SizedBox(height: 5),
                TextField(
                  controller: controller.matpelC,
                  decoration: InputDecoration(
                    hintText: "Contoh: Biologi Lintas Minat",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(height: 1, thickness: 1),

          Obx(() {
            if (controller.listSiswa.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Daftar Siswa", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      icon: Icon(Icons.checklist, size: 18),
                      label: Text("Hadir Semua", style: GoogleFonts.poppins(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => controller.setSemuaStatus('Hadir'),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),
          
          // --- LIST DATA SISWA UNTUK DICENTANG ---
          // --- LIST DATA SISWA UNTUK DICENTANG ---
          Expanded(
            child: Obx(() {
              if (controller.isFetchingSiswa.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (controller.selectedKelasId.value.isEmpty) {
                return Center(child: Text("Silakan pilih kelas terlebih dahulu.", style: GoogleFonts.poppins(color: Colors.grey)));
              }
              if (controller.listSiswa.isEmpty) {
                return Center(child: Text("Tidak ada siswa di kelas ini.", style: GoogleFonts.poppins(color: Colors.grey)));
              }

              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: controller.listSiswa.length,
                itemBuilder: (context, index) {
                  var siswa = controller.listSiswa[index];
                  int idSiswa = siswa['id'];

                  return Card(
                    elevation: 1,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.blue[100],
                                backgroundImage: siswa['foto_profil'] != null ? NetworkImage("${ApiConfig.imageUrl}${siswa['foto_profil']}") : null,
                                child: siswa['foto_profil'] == null ? Icon(Icons.person, size: 18, color: Colors.blue[800]) : null,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  siswa['nama'],
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          
                          // TOGGLE STATUS ABSEN (Hadir / Sakit / Izin / Alpa)
                          Obx(() {
                            String currentStatus = controller.statusPresensi[idSiswa] ?? 'Hadir';
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatusRadio(idSiswa, "Hadir", currentStatus, Colors.green),
                                    _buildStatusRadio(idSiswa, "Sakit", currentStatus, Colors.orange),
                                    _buildStatusRadio(idSiswa, "Izin", currentStatus, Colors.blue),
                                    _buildStatusRadio(idSiswa, "Alpa", currentStatus, Colors.red),
                                  ],
                                ),
                                
                                // --- INPUT KETERANGAN MUNCUL JIKA SAKIT ATAU IZIN ---
                                if (currentStatus == 'Sakit' || currentStatus == 'Izin')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: TextField(
                                      onChanged: (val) => controller.updateCatatan(idSiswa, val),
                                      maxLines: 1,
                                      style: GoogleFonts.poppins(fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: "Masukkan keterangan $currentStatus...",
                                        hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                        prefixIcon: Icon(Icons.edit_note, size: 20, color: Colors.grey),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          
          // --- TOMBOL SIMPAN ---
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
            child: Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.submitPresensi(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: controller.isLoading.value 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("SIMPAN PRESENSI KELAS", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )),
          )
        ],
      ),
    );
  }

  // WIDGET HELPER BUTTON RADIO
  Widget _buildStatusRadio(int siswaId, String title, String currentStatus, Color color) {
    bool isSelected = currentStatus == title;
    return GestureDetector(
      onTap: () => controller.updateStatus(siswaId, title),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}