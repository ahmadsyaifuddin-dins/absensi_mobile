import 'package:absensi/app/modules/home/views/detail_foto_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../data/providers/api_config.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ValidasiIzinController extends GetxController {
  var listIzin = [].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchIzin();
  }

  // 1. AMBIL DATA (FIXED URL)
  Future<void> fetchIzin() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      // URL disesuaikan dengan LaporanController.php
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/laporan/pengajuan-izin'), 
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        listIzin.value = data;
      } else {
        print("Gagal fetch izin: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. FUNGSI APPROVE / REJECT (FIXED URL & BODY)
  Future<void> updateStatus(int id, String aksi) async {
    try {
      final box = GetStorage();
      // PERBAIKAN: URL dan Body disesuaikan dengan LaporanController.php
      var response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/laporan/verifikasi-izin'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'},
        // Body harus 'absensi_id' dan 'aksi' (Sesuai LaporanController)
        body: {
          'absensi_id': id.toString(), 
          'aksi': aksi // "Diterima" atau "Ditolak"
        }
      );

      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Izin berhasil $aksi", backgroundColor: Colors.green, colorText: Colors.white);
        fetchIzin(); // Refresh list setelah update
      } else {
        Get.snackbar("Gagal", "Server Error: ${response.statusCode}", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal koneksi: $e");
    }
  }
}

class ValidasiIzinView extends StatelessWidget {
  final controller = Get.put(ValidasiIzinController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Validasi Izin Siswa", style: GoogleFonts.poppins()),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return Center(child: CircularProgressIndicator());
        
        if (controller.listIzin.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_turned_in, size: 80, color: Colors.grey[300]),
                SizedBox(height: 10),
                Text("Tidak ada pengajuan izin baru.", style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: controller.listIzin.length,
          itemBuilder: (context, index) {
            var item = controller.listIzin[index];
            var user = item['user'] ?? {'nama': 'Siswa', 'kelas': {'nama_kelas': '-'}};
            var kelas = user['kelas'] ?? {'nama_kelas': '-'};
            
            // Cek Status Validasi
            String validasi = item['validasi'] ?? 'Pending';
            
            // Format Tanggal
            String tanggalFormatted = "-";
            try {
               tanggalFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.parse(item['tanggal']));
            } catch (e) {}

            return Card(
              margin: EdgeInsets.only(bottom: 15),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Nama & Kelas
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.indigo[50],
                          child: Icon(
                            item['status'] == 'Sakit' ? Icons.local_hospital : Icons.assignment, 
                            color: item['status'] == 'Sakit' ? Colors.orange : Colors.blue
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['nama'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("${kelas['nama_kelas']} • $tanggalFormatted", style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                        // Badge Status Izin (Sakit/Izin)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item['status'] == 'Sakit' ? Colors.orange[100] : Colors.blue[100],
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(item['status'], style: TextStyle(
                            color: item['status'] == 'Sakit' ? Colors.orange[800] : Colors.blue[800],
                            fontWeight: FontWeight.bold, fontSize: 10
                          )),
                        )
                      ],
                    ),
                    
                    Divider(height: 20),
                    
                    // Alasan
                    Text("Alasan:", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text(item['catatan'] ?? "-", style: GoogleFonts.poppins(fontSize: 14)),
                    
                    // Foto Bukti (Kalau ada)
                    if (item['bukti_izin'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => DetailFotoView(
                              imageUrl: "${ApiConfig.imageUrl}${item['bukti_izin']}"
                            ));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  "${ApiConfig.imageUrl}${item['bukti_izin']}",
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    height: 100, width: double.infinity, color: Colors.grey[200],
                                    child: Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                ),
                                Positioned(
                                  bottom: 5, right: 5,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    color: Colors.black54,
                                    child: Icon(Icons.zoom_in, color: Colors.white, size: 18),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Tombol Aksi (Hanya muncul kalau masih Pending)
                    if (validasi == 'Pending')
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.check, size: 18),
                                onPressed: () => controller.updateStatus(item['id'], 'Diterima'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green, 
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                                ),
                                label: Text("Terima"),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.close, size: 18),
                                onPressed: () => controller.updateStatus(item['id'], 'Ditolak'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red, 
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                                ),
                                label: Text("Tolak"),
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}