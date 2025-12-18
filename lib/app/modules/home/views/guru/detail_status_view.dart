import 'package:absensi/app/modules/home/views/detail_foto_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../../data/providers/api_config.dart';

class DetailStatusView extends StatefulWidget {
  final String title;   // Contoh: "Siswa Belum Absen"
  final String status;  // Contoh: "belum", "hadir", "sakit", "izin"
  final Color themeColor; // Warna tema header

  const DetailStatusView({
    Key? key, 
    required this.title, 
    required this.status,
    required this.themeColor,
  }) : super(key: key);

  @override
  State<DetailStatusView> createState() => _DetailStatusViewState();
}

class _DetailStatusViewState extends State<DetailStatusView> {
  bool isLoading = true;
  List<dynamic> listSiswa = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final box = GetStorage();
    try {
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/detail-status?status=${widget.status}'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          listSiswa = jsonDecode(response.body)['data'];
          isLoading = false;
        });
      } else {
        Get.snackbar("Error", "Gagal memuat data");
      }
    } catch (e) {
      print("Error Detail: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: widget.themeColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator()) 
          : listSiswa.isEmpty 
              ? Center(child: Text("Tidak ada data siswa", style: GoogleFonts.poppins())) 
              : ListView.builder(
                  padding: EdgeInsets.all(15),
                  itemCount: listSiswa.length,
                  itemBuilder: (context, index) {
                    var item = listSiswa[index];
                    var kelas = item['kelas'] != null ? item['kelas']['nama_kelas'] : '-';
                    var info = item['info_tambahan'] ?? '-'; // Jam masuk / Catatan

                    return Card(
                      margin: EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: widget.themeColor.withOpacity(0.1),
                          backgroundImage: item['foto_profil'] != null 
                              ? NetworkImage("${ApiConfig.imageUrl}${item['foto_profil']}") 
                              : null,
                          child: item['foto_profil'] == null 
                              ? Text(item['nama'][0], style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold))
                              : null,
                        ),
                        title: Text(item['nama'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$kelas • ${item['nisn_nip'] ?? '-'}", style: TextStyle(fontSize: 12)),
                            if (widget.status != 'belum') // Kalau hadir/izin tampilkan jam/alasan
                              Text(
                                widget.status == 'hadir' ? "Masuk: $info" : "Alasan: $info",
                                style: TextStyle(fontSize: 11, color: Colors.grey[700], fontStyle: FontStyle.italic)
                              ),
                          ],
                        ),
                        trailing: (widget.status == 'izin' || widget.status == 'sakit') && item['bukti_izin'] != null
                          ? IconButton(
                              icon: Icon(Icons.image, color: Colors.blue),
                              onPressed: () {
                                Get.to(() => DetailFotoView(imageUrl: "${ApiConfig.imageUrl}${item['bukti_izin']}"));
                              },
                            )
                          : null,
                      ),
                    );
                  },
                ),
              );
            }
          }