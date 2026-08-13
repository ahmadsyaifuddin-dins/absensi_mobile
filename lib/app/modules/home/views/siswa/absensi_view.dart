import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart'; // Untuk hitung jarak di UI
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/absensi_controller.dart';

class AbsensiView extends StatefulWidget {
  // Terima token dari halaman sebelumnya
  final String tokenUser;
  const AbsensiView({super.key, required this.tokenUser});

  @override
  State<AbsensiView> createState() => _AbsensiViewState();
}

class _AbsensiViewState extends State<AbsensiView> {
  final AbsensiController controller = Get.put(AbsensiController());

  @override
  void initState() {
    super.initState();
    // Inisialisasi kamera depan + face detection saat halaman dibuka
    controller.initCamera();
  }

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

            // --- 2. KAMERA LIVE + FACE DETECTION ---
            _buildCameraSection(),

            SizedBox(height: 30),

            // --- 3. TOMBOL KIRIM (Aktif hanya jika wajah terdeteksi) ---
            Obx(() => SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: (controller.isLoading.value || !controller.isFaceDetected.value)
                    ? null
                    : () => controller.absenMasuk(widget.tokenUser),
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

  // WIDGET KAMERA LIVE (Stream + Face Detection)
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
          Text("Foto Selfie (Deteksi Wajah)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          SizedBox(height: 15),
          
          // LIVE PREVIEW KAMERA
          Obx(() {
            if (controller.cameraError.value.isNotEmpty) {
              return _buildCameraPlaceholder(
                icon: Icons.no_photography,
                text: controller.cameraError.value,
                isError: true,
              );
            }
            if (!controller.isCameraReady.value || controller.cameraController == null) {
              return _buildCameraPlaceholder(
                icon: Icons.camera_alt,
                text: "Menyiapkan kamera...",
                showLoader: true,
              );
            }
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 260,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.cameraController!.value.previewSize!.height,
                    height: controller.cameraController!.value.previewSize!.width,
                    child: CameraPreview(controller.cameraController!),
                  ),
                ),
              ),
            );
          }),

          SizedBox(height: 12),

          // STATUS DETEKSI WAJAH
          Obx(() {
            if (!controller.isCameraReady.value) return const SizedBox.shrink();
            final detected = controller.isFaceDetected.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  detected ? Icons.face : Icons.face_retouching_off,
                  color: detected ? Colors.green : Colors.orange,
                  size: 22,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    detected ? "Wajah terdeteksi" : "Arahkan kamera ke wajah Anda",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: detected ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // Placeholder saat kamera belum siap / error
  Widget _buildCameraPlaceholder({required IconData icon, required String text, bool showLoader = false, bool isError = false}) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLoader)
            CircularProgressIndicator()
          else
            Icon(icon, size: 50, color: isError ? Colors.red : Colors.grey),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: isError ? Colors.red : Colors.grey,
                fontWeight: isError ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
