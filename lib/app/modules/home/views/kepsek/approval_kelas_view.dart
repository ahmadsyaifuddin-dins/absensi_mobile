import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/approval_controller.dart';

class ApprovalKelasView extends StatelessWidget {
  // Panggil Controller
  final ApprovalController controller = Get.put(ApprovalController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approval Kelas & Wali", style: GoogleFonts.poppins()),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      
      floatingActionButton: Obx(() {
        // Tombol hanya muncul jika ada data yang pending
        if (controller.listKelasPending.isNotEmpty && !controller.isLoading.value) {
          return FloatingActionButton.extended(
            onPressed: () {
              Get.defaultDialog(
                title: "Sah-kan Semua?",
                middleText: "Dengan ini Kepsek menyetujui SEMUA pembagian kelas yang ada di daftar ini.",
                textConfirm: "Ya, Sah-kan Semua",
                textCancel: "Batal",
                confirmTextColor: Colors.white,
                buttonColor: Colors.green,
                onConfirm: () {
                  Get.back(); // Tutup dialog
                  controller.approveAllKelas();
                }
              );
            },
            backgroundColor: Colors.green,
            icon: Icon(Icons.done_all, color: Colors.white),
            label: Text("Approve Semua", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          );
        }
        return SizedBox.shrink(); // Sembunyikan jika tidak ada data pending
      }),
      body: Obx(() {
        if (controller.isLoading.value && controller.listKelasPending.isEmpty) {
          return Center(child: CircularProgressIndicator(color: Colors.orange));
        }

        if (controller.listKelasPending.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
                SizedBox(height: 15),
                Text("Semua data kelas sudah disahkan!", style: GoogleFonts.poppins(color: Colors.grey[600])),
              ],
            )
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: controller.listKelasPending.length,
          itemBuilder: (context, index) {
            var item = controller.listKelasPending[index];
            
            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor: Colors.orange[100],
                  child: Icon(Icons.class_, color: Colors.orange[800]),
                ),
                title: Text(item['nama_kelas'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "Jumlah Siswa: ${item['siswa_count'] ?? 0}\nStatus: Menunggu Pengesahan", 
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])
                ),
                isThreeLine: true,
                trailing: ElevatedButton(
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Sah-kan Kelas?",
                      middleText: "Dengan ini Kepsek menyetujui pembagian kelas ${item['nama_kelas']}.",
                      textConfirm: "Ya, Sah-kan",
                      textCancel: "Batal",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.green,
                      onConfirm: () {
                        Get.back(); // Tutup dialog
                        controller.approveKelas(item['id'].toString());
                      }
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: Text("Approve", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}