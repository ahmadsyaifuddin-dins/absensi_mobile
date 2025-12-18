import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../controllers/absensi_controller.dart';
import '../../../../data/providers/api_config.dart';

class RiwayatView extends StatelessWidget {
  final AbsensiController controller = Get.put(AbsensiController());

  @override
  Widget build(BuildContext context) {
    // Inisialisasi format tanggal Indonesia
    initializeDateFormatting('id_ID', null); 

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
                  // FOTO
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: item.fotoMasuk != null || item.buktiIzin != null
                      // Logic: Kalau ada foto selfie pakai itu, kalau gak ada cek bukti izin
                      ? Image.network(
                          "${ApiConfig.imageUrl}${item.fotoMasuk ?? item.buktiIzin}",
                          width: 60, height: 60, fit: BoxFit.cover,
                          errorBuilder: (c,e,s) => Container(width: 60, height: 60, color: Colors.grey[200], child: Icon(Icons.broken_image)),
                        )
                      : Container(width: 60, height: 60, color: Colors.grey[200], child: Icon(Icons.person)),
                  ),
                  SizedBox(width: 15),
                  
                  // TEXT INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(item.tanggal),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        if (item.status == 'Hadir')
                          Text("Masuk: ${item.jamMasuk ?? '-'}", style: GoogleFonts.poppins(fontSize: 12))
                        else 
                          Text("Alasan: ${item.catatan ?? '-'}", style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic)),
                        
                        if (item.terlambat == true)
                          Text("Telat ${item.menitKeterlambatan} menit", style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 11)),
                      ],
                    ),
                  ),

                  // LABEL STATUS
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getColor(item.status!).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status ?? "Hadir",
                      style: GoogleFonts.poppins(
                        color: _getColor(item.status!), 
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

  Color _getColor(String status) {
    if (status == 'Hadir') return Colors.green[800]!;
    if (status == 'Sakit') return Colors.orange[800]!;
    if (status == 'Izin') return Colors.blue[800]!;
    return Colors.red;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      // TAMBAHKAN .toLocal() DI SINI
      // Gunanya mengubah waktu server (UTC) menjadi waktu HP User (WITA/WIB)
      DateTime dt = DateTime.parse(dateStr).toLocal(); 
      
      return DateFormat('EEEE, d MMMM y', 'id_ID').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}