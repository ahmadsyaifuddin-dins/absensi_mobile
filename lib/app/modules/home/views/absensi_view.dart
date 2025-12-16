import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/absensi_controller.dart';

class AbsensiView extends StatelessWidget {
  final String tokenUser;
  AbsensiView({required this.tokenUser});

  // Inject Controller
  final AbsensiController controller = Get.put(AbsensiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Absensi Masuk", style: GoogleFonts.poppins()),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. INFORMASI LOKASI
            Obx(() => Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: controller.isInArea.value ? Colors.green[50] : Colors.red[50],
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
                    size: 30,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.isInArea.value ? "Di Dalam Area" : "Di Luar Jangkauan",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: controller.isInArea.value ? Colors.green : Colors.red),
                        ),
                        Text(
                          controller.address.value,
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.determinePosition(), 
                    icon: Icon(Icons.refresh, color: Colors.grey)
                  )
                ],
              ),
            )),
            
            SizedBox(height: 20),

            // 2. PREVIEW FOTO BESAR
            Obx(() => Container(
              height: 350, // Lebih besar biar enak selfie
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
                image: controller.imageFile.value != null 
                  ? DecorationImage(
                      image: FileImage(controller.imageFile.value!),
                      fit: BoxFit.cover
                    )
                  : null
              ),
              child: controller.imageFile.value == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_enhance, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Pastikan wajah terlihat jelas", style: GoogleFonts.poppins(color: Colors.grey))
                      ],
                    )
                  : null,
            )),

            SizedBox(height: 25),

            // 3. TOMBOL AKSI
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.pickImage(), 
                    icon: Icon(Icons.camera_alt), 
                    label: Text("Ambil Foto"),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Obx(() => ElevatedButton.icon(
                    onPressed: (controller.isLoading.value || !controller.isInArea.value || controller.imageFile.value == null) 
                      ? null 
                      : () => controller.submitAbsen(tokenUser),
                    icon: controller.isLoading.value ? SizedBox() : Icon(Icons.send),
                    label: controller.isLoading.value 
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Kirim Absen"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}