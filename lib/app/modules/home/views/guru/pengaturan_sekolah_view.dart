import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/sekolah_controller.dart';

class PengaturanSekolahView extends StatelessWidget {
  final controller = Get.put(SekolahController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan Sistem", style: GoogleFonts.poppins()),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.namaSekolahC.text.isEmpty) {
           return Center(child: CircularProgressIndicator());
        }
       
        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Identitas Sekolah"),
              SizedBox(height: 10),
              _buildTextField("Nama Sekolah", controller.namaSekolahC, icon: Icons.school),
             
              SizedBox(height: 20),
              _buildSectionTitle("Waktu Masuk"),
              SizedBox(height: 10),
             
              _buildTextField(
                "Jam Masuk (WITA)",
                controller.jamMasukC,
                icon: Icons.access_time,
                readOnly: true, 
                onTap: () {
                   controller.selectTime(context); 
                }
              ),

              SizedBox(height: 30),
              _buildSectionTitle("Koordinat Lokasi"),
              SizedBox(height: 10),
              _buildTextField("Latitude", controller.latC, icon: Icons.map),
              SizedBox(height: 10),
              _buildTextField("Longitude", controller.longC, icon: Icons.map),
             
              SizedBox(height: 20),
              _buildSectionTitle("Zona Absensi"),
              SizedBox(height: 10),
              _buildTextField("Radius (Meter)", controller.radiusC, icon: Icons.radar, isNumber: true),
             
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Siswa hanya bisa absen jika berada dalam jarak ${controller.radiusC.text.isEmpty ? '0' : controller.radiusC.text} meter dari titik koordinat di atas.",
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),

              // --- [BARU] WHATSAPP GATEWAY (FONNTE) ---
              SizedBox(height: 30),
              _buildSectionTitle("WhatsApp Gateway"),
              SizedBox(height: 10),
              _buildTextField("Token API Fonnte", controller.fonnteTokenC, icon: Icons.message),
              SizedBox(height: 5),
              Text(
                "*Dapatkan token acak dari menu API di dashboard fonnte.com setelah menghubungkan nomor WA sekolah.",
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
              ),

              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.simpanPengaturan(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                  child: controller.isLoading.value 
                      ? CircularProgressIndicator(color: Colors.white) 
                      : Text("SIMPAN PENGATURAN", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    {
      IconData? icon,
      bool isNumber = false,
      bool readOnly = false, 
      VoidCallback? onTap    
    }
  ) {
    return TextField(
      controller: controller,
      readOnly: readOnly, 
      onTap: onTap,       
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}