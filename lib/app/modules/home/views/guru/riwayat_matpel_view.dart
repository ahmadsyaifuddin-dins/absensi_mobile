import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/matpel_controller.dart';

class RiwayatMatpelView extends StatelessWidget {
  final MatpelController controller = Get.put(MatpelController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Riwayat Absensi Kelas", style: GoogleFonts.poppins()),
        backgroundColor: Colors.blue[800], // Samakan tema dengan input
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        if (controller.isLoadingRiwayat.value) {
          return Center(child: CircularProgressIndicator(color: Colors.blue[800]));
        }

        if (controller.riwayatSiswaMatpel.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
                SizedBox(height: 10),
                Text("Belum ada riwayat presensi hari ini.", style: GoogleFonts.poppins(color: Colors.grey[600])),
              ],
            )
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: controller.riwayatSiswaMatpel.length,
          itemBuilder: (context, index) {
            var item = controller.riwayatSiswaMatpel[index];
            String namaSiswa = item['siswa'] != null ? item['siswa']['nama'] : 'Siswa Tidak Diketahui';
            String namaKelas = item['kelas'] != null ? item['kelas']['nama_kelas'] : '-';
            String status = item['status'] ?? 'Alpa';
            String matpel = item['matpel'] ?? 'Mata Pelajaran';
            // Ambil data catatan dari API
            String catatan = item['catatan'] ?? '';
            
            // Tentukan Warna Berdasarkan Status
            Color statusColor;
            if (status == 'Hadir') statusColor = Colors.green;
            else if (status == 'Sakit') statusColor = Colors.orange;
            else if (status == 'Izin') statusColor = Colors.blue;
            else statusColor = Colors.red;

            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(Icons.person, color: statusColor),
                ),
                title: Text(namaSiswa, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      "$namaKelas • $matpel",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "Pukul: ${item['waktu_presensi']}",
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                    ),
                    
                    // --- KONDISIONAL RENDER CATATAN (HANYA SAKIT & IZIN) ---
                    if ((status == 'Sakit' || status == 'Izin') && catatan.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.notes, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "\"$catatan\"",
                                style: GoogleFonts.poppins(
                                  fontSize: 11, 
                                  color: Colors.grey[700], 
                                  fontStyle: FontStyle.italic
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // --- END CATATAN ---
                    
                  ],
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status, 
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}