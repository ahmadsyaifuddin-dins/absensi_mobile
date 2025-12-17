import 'package:absensi/app/modules/home/views/detail_foto_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../data/providers/api_config.dart';
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

  // 1. AMBIL DATA
  Future<void> fetchIzin() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/izin/list'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        listIzin.value = data;
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. FUNGSI APPROVE / REJECT
  Future<void> updateStatus(int id, String status) async {
    try {
      final box = GetStorage();
      var response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/izin/approve/$id'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'},
        body: {'validasi': status}
      );

      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Izin $status");
        fetchIzin(); // Refresh list setelah update
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal update status");
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
        if (controller.listIzin.isEmpty) return Center(child: Text("Belum ada pengajuan izin."));

        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: controller.listIzin.length,
          itemBuilder: (context, index) {
            var item = controller.listIzin[index];
            var user = item['user'] ?? {'nama': 'Siswa'};
            
            // Cek Status Validasi
            String validasi = item['validasi'] ?? 'Pending';
            Color statusColor = validasi == 'Diterima' ? Colors.green 
                              : validasi == 'Ditolak' ? Colors.red 
                              : Colors.orange;

            return Card(
              margin: EdgeInsets.only(bottom: 15),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Nama & Tanggal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(user['nama'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(item['tanggal']).toLocal()),
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text("Alasan: ${item['catatan']}", style: GoogleFonts.poppins()),
                    
                    // Status Badge
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: statusColor)
                      ),
                      child: Text(validasi, style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold)),
                    ),

                    // Foto Bukti (Kalau ada)
                    if (item['bukti_izin'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: GestureDetector(
                          onTap: () {
                            // SAAT DIKLIK -> PINDAH KE DETAIL FOTO
                            Get.to(() => DetailFotoView(
                              imageUrl: "${ApiConfig.imageUrl}${item['bukti_izin']}"
                            ));
                          },
                          child: Hero( // Efek animasi smooth saat pindah halaman
                            tag: "foto_${item['id']}", 
                            child: Image.network(
                              "${ApiConfig.imageUrl}${item['bukti_izin']}",
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (ctx, err, stack) {
                                return Container(
                                  height: 150,
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: Text("Gagal muat gambar", style: GoogleFonts.poppins(color: Colors.grey)),
                                );
                              },
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
                              child: ElevatedButton(
                                onPressed: () => controller.updateStatus(item['id'], 'Diterima'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: Text("Terima"),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => controller.updateStatus(item['id'], 'Ditolak'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                child: Text("Tolak"),
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