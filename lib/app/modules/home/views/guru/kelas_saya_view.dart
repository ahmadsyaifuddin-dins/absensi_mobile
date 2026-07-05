import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/kelas_saya_controller.dart';
import 'data_siswa_view.dart'; // Nanti kita arahkan ke sini untuk lihat anak muridnya

class KelasSayaView extends StatelessWidget {
  final controller = Get.put(KelasSayaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kelas Binaan Saya", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100], 
      body: Obx(() {
        if (controller.isLoading.value) return Center(child: CircularProgressIndicator(color: Colors.teal));
       
        // Jika guru ini bukan wali kelas sama sekali
        if (controller.listKelasKu.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey[400]),
                SizedBox(height: 15),
                Text(
                  "Anda belum ditunjuk sebagai Wali Kelas.", 
                  style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16)
                ),
              ],
            )
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: controller.listKelasKu.length,
          itemBuilder: (context, index) {
            var item = controller.listKelasKu[index];
            var jumlahSiswa = item['siswa_count'] ?? 0;
            
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.white,
              child: ListTile(
                contentPadding: EdgeInsets.all(20),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal[100],
                  child: Icon(Icons.class_, color: Colors.teal[800], size: 30),
                ),
                title: Text(
                  item['nama_kelas'],
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Total: $jumlahSiswa Anak Didik",
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Fitur lanjutan: Arahkan ke Data Siswa tapi difilter khusus kelas ini
                    Get.snackbar("Info", "Membuka daftar siswa kelas ${item['nama_kelas']}", backgroundColor: Colors.teal, colorText: Colors.white);
                    Get.to(() => DataSiswaView(kelasId: item['id'].toString()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: Text("Lihat Siswa", style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}