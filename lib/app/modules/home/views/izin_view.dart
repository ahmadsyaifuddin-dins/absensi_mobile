import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/absensi_controller.dart';

class IzinView extends StatelessWidget {
  final AbsensiController controller = Get.put(AbsensiController());

  @override
  Widget build(BuildContext context) {
    // Reset form
    controller.image.value = null; // Variable sudah diganti jadi 'image'
    controller.alasanC.clear();

    return Scaffold(
      appBar: AppBar(
        title: Text("Pengajuan Izin", style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kategori", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.kategoriIzin.value,
              items: ['Sakit', 'Izin'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => controller.kategoriIzin.value = val!,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: 15)
              ),
            )),
            
            SizedBox(height: 20),
            
            Text("Alasan / Keterangan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: controller.alasanC,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Contoh: Demam tinggi sejak semalam...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            SizedBox(height: 20),

            Text("Foto Surat Dokter / Bukti", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            
            // Preview Foto
            Obx(() => GestureDetector(
              // Di sini kita bisa pilih mau Kamera atau Galeri
              // Contoh: Pakai Galeri untuk surat izin
              onTap: () => controller.pickImage(ImageSource.gallery), 
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: controller.image.value != null 
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        controller.image.value!, // Pakai 'image' bukan 'imageFile'
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                        Text("Tap untuk upload foto", style: GoogleFonts.poppins(color: Colors.grey))
                      ],
                    ),
              ),
            )),

            SizedBox(height: 30),

            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value 
                  ? null 
                  : () {
                      final box = GetStorage();
                      String? token = box.read('token');
                      if (token != null) controller.submitIzin(token);
                    },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: controller.isLoading.value 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("KIRIM PENGAJUAN", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              )),
            )
          ],
        ),
      ),
    );
  }
}