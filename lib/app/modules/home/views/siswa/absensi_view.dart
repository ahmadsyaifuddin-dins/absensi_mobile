import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart'; // Untuk hitung jarak di UI
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/absensi_controller.dart';

class AbsensiView extends StatelessWidget {
  // Terima token dari halaman sebelumnya
  final String tokenUser;
  AbsensiView({required this.tokenUser});

  final AbsensiController controller = Get.put(AbsensiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Absen Masuk", style: GoogleFonts.poppins()),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. STATUS LOKASI ---
            _buildLocationCard(),

            SizedBox(height: 20),

            // --- 2. FOTO SELFIE ---
            _buildCameraSection(),

            SizedBox(height: 30),

            // --- 3. TOMBOL KIRIM ---
            Obx(() => SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.absenMasuk(tokenUser),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: controller.isLoading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("KIRIM ABSENSI SEKARANG", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  // WIDGET KARTU LOKASI
  Widget _buildLocationCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Icon(Icons.location_on, size: 40, color: Colors.redAccent),
          SizedBox(height: 10),
          Text("Lokasi Anda Saat Ini", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
          SizedBox(height: 5),
          
          // ALAMAT DARI CONTROLLER
          Obx(() => Text(
            controller.alamat.value,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          )),
          
          Divider(height: 30),

          // INDIKATOR JARAK (Hijau/Merah)
          Obx(() {
            if (controller.currentPosition.value == null) {
              return Text("Menunggu GPS...", style: TextStyle(color: Colors.orange));
            }

            // Hitung Jarak Realtime untuk UI
            double jarak = Geolocator.distanceBetween(
              controller.currentPosition.value!.latitude,
              controller.currentPosition.value!.longitude,
              controller.schoolLat.value,
              controller.schoolLng.value
            );

            bool isInArea = jarak <= controller.radiusMeter.value;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isInArea ? Icons.check_circle : Icons.cancel,
                  color: isInArea ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  isInArea 
                    ? "Di Dalam Area (${jarak.toInt()}m)" 
                    : "Di Luar Area (${jarak.toInt()}m)",
                  style: GoogleFonts.poppins(
                    color: isInArea ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // WIDGET KAMERA
  Widget _buildCameraSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Text("Foto Selfie", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          SizedBox(height: 15),
          
          // PREVIEW FOTO
          Obx(() {
            return controller.image.value == null
              ? Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                      Text("Belum ada foto", style: GoogleFonts.poppins(color: Colors.grey))
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    controller.image.value!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
          }),

          SizedBox(height: 15),
          
          // TOMBOL AMBIL FOTO
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => controller.pickImage(),
              icon: Icon(Icons.camera_alt),
              label: Text("Ambil Foto"),
              style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
            ),
          )
        ],
      ),
    );
  }
}