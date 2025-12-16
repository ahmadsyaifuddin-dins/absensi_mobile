import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/absensi_controller.dart';
import '../../../data/providers/api_config.dart';

class RiwayatView extends StatelessWidget {
  // Panggil Controller yang sama
  final AbsensiController controller = Get.put(AbsensiController());

  @override
  Widget build(BuildContext context) {
    // Panggil fetchHistory saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchHistory();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Riwayat Kehadiran", style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Obx(() {
        if (controller.isLoadingHistory.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.historyList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
                SizedBox(height: 10),
                Text("Belum ada data absensi", style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: controller.historyList.length,
          itemBuilder: (context, index) {
            var item = controller.historyList[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 3))
                ]
              ),
              child: Row(
                children: [
                  // FOTO BUKTI
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: item.fotoMasuk != null
                      ? Image.network(
                          "${ApiConfig.imageUrl}${item.fotoMasuk}",
                          width: 60, height: 60, fit: BoxFit.cover,
                          errorBuilder: (c,e,s) => Container(width: 60, height: 60, color: Colors.grey[200], child: Icon(Icons.broken_image)),
                        )
                      : Container(width: 60, height: 60, color: Colors.grey[200], child: Icon(Icons.person)),
                  ),
                  SizedBox(width: 15),
                  
                  // DETAIL ABSEN
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(item.tanggal),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey),
                            SizedBox(width: 5),
                            Text("Masuk: ${item.jamMasuk ?? '-'}", style: GoogleFonts.poppins(fontSize: 12)),
                          ],
                        ),
                        if (item.terlambat == true)
                          Text(
                            "Telat ${item.menitKeterlambatan} menit",
                            style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 11, fontStyle: FontStyle.italic),
                          )
                      ],
                    ),
                  ),

                  // LABEL STATUS
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.terlambat == true ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status ?? "Hadir",
                      style: GoogleFonts.poppins(
                        color: item.terlambat == true ? Colors.orange[800] : Colors.green[800], 
                        fontWeight: FontWeight.bold, 
                        fontSize: 12
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('EEEE, d MMMM y', 'id_ID').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}