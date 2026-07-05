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
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoadingRiwayat.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.riwayatSiswaMatpel.isEmpty) {
          return Center(child: Text("Belum ada siswa yang absen hari ini.", style: GoogleFonts.poppins()));
        }

        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: controller.riwayatSiswaMatpel.length,
          itemBuilder: (context, index) {
            var item = controller.riwayatSiswaMatpel[index];
            return Card(
              margin: EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.withOpacity(0.1),
                  child: Icon(Icons.person, color: Colors.indigo),
                ),
                title: Text(item['siswa']['nama'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "${item['siswa']['kelas']['nama_kelas']} • ${item['waktu_presensi']}",
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: Chip(
                  label: Text(item['status'], style: GoogleFonts.poppins(fontSize: 10, color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}