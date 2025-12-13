import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/absensi_controller.dart';

class AbsensiView extends StatelessWidget {
  // Terima token dari Home
  final String tokenUser;
  AbsensiView({required this.tokenUser});

  final AbsensiController controller = Get.put(AbsensiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Absensi Masuk")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. INFORMASI LOKASI
            Obx(() => Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: controller.isInArea.value ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: controller.isInArea.value ? Colors.green : Colors.red
                )
              ),
              child: Row(
                children: [
                  Icon(
                    controller.isInArea.value ? Icons.check_circle : Icons.warning,
                    color: controller.isInArea.value ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      controller.address.value,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh), 
                    onPressed: () => controller.determinePosition()
                  )
                ],
              ),
            )),
            
            SizedBox(height: 20),

            // 2. PREVIEW FOTO
            Obx(() => Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                image: controller.imageFile.value != null 
                  ? DecorationImage(
                      image: FileImage(controller.imageFile.value!),
                      fit: BoxFit.cover
                    )
                  : null
              ),
              child: controller.imageFile.value == null
                  ? Center(child: Icon(Icons.camera_alt, size: 50, color: Colors.grey))
                  : null,
            )),

            SizedBox(height: 15),

            // 3. TOMBOL AMBIL FOTO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.pickImage(), 
                icon: Icon(Icons.camera), 
                label: Text("Ambil Foto Selfie")
              ),
            ),

            SizedBox(height: 30),

            // 4. TOMBOL SUBMIT (Kirim ke Server)
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (controller.isLoading.value || !controller.isInArea.value) 
                  ? null // Disable kalau loading ATAU diluar area
                  : () => controller.submitAbsen(tokenUser),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: controller.isLoading.value 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("KIRIM ABSENSI SEKARANG", 
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ))
          ],
        ),
      ),
    );
  }
}