import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/rekap_kelas_controller.dart';

class RekapKelasView extends StatelessWidget {
  final controller = Get.put(RekapKelasController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rekap Kelas", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100], // Biar background gak terlalu putih kaku
      body: Obx(() {
        if (controller.isLoading.value) return Center(child: CircularProgressIndicator());
       
        if (controller.listKelas.isEmpty) {
          return Center(child: Text("Belum ada data kelas", style: GoogleFonts.poppins(color: Colors.grey)));
        }

        return GridView.builder(
          padding: EdgeInsets.all(15),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1, // Disesuaikan sedikit biar badge-nya muat
          ),
          itemCount: controller.listKelas.length,
          itemBuilder: (context, index) {
            var item = controller.listKelas[index];
            var jumlahSiswa = item['siswa_count'] ?? 0;
            
            // --- LOGIC STATUS APPROVAL ---
            String status = item['status_approval'] ?? 'pending';
            bool isApproved = status == 'approved';

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.white,
              child: InkWell(
                onTap: () => _showDialog(context, item),
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.class_, 
                          size: 40, 
                          color: isApproved ? Colors.teal : Colors.orange // Warna icon ngikutin status
                        ),
                        SizedBox(height: 10),
                        Text(
                          item['nama_kelas'],
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          "$jumlahSiswa Siswa",
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        
                        // --- BADGE STATUS APPROVAL ---
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isApproved ? Colors.green[50] : Colors.orange[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isApproved ? Colors.green[300]! : Colors.orange[300]!,
                            )
                          ),
                          child: Text(
                            isApproved ? "Disahkan" : "Menunggu",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isApproved ? Colors.green[700] : Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showDialog(context, null),
      ),
    );
  }

  // Dialog Tambah / Edit
  void _showDialog(BuildContext context, Map? item) {
    if (item != null) {
      controller.namaKelasC.text = item['nama_kelas'];
    } else {
      controller.namaKelasC.clear();
    }

    Get.defaultDialog(
      title: item == null ? "Tambah Kelas" : "Edit Kelas",
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextField(
          controller: controller.namaKelasC,
          decoration: InputDecoration(
            labelText: "Nama Kelas (Contoh: XII RPL 1)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      textConfirm: "SIMPAN",
      textCancel: "BATAL",
      confirmTextColor: Colors.white,
      buttonColor: Colors.teal,
      onConfirm: () {
        controller.simpanKelas(id: item != null ? item['id'].toString() : null);
      },
      actions: item != null ? [
        TextButton(
          onPressed: () {
            Get.back();
            Get.defaultDialog(
              title: "Hapus?",
              middleText: "Yakin hapus kelas ini?",
              textConfirm: "Ya, Hapus",
              confirmTextColor: Colors.white,
              buttonColor: Colors.red,
              onConfirm: () {
                Get.back(); // Tutup confirm
                controller.hapusKelas(item['id']);
              }
            );
          },
          child: Text("Hapus Kelas Ini", style: GoogleFonts.poppins(color: Colors.red)),
        )
      ] : null
    );
  }
}