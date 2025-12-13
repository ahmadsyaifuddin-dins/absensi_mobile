import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../data/providers/api_config.dart';

class AbsensiController extends GetxController {
  var isLoading = false.obs;
  var address = "Mencari lokasi...".obs;
  var isInArea = false.obs;
  
  // Data Lokasi
  Position? currentPosition;
  // Koordinat Sekolah
  // final double schoolLat = -3.3189565918609256; 
  // final double schoolLng = 114.61626673414588;
  // final double radiusKm = 0.05; // 50 meter

  // GANTI DENGAN KOORDINAT RUMAH (UNTUK TESTING)
  final double schoolLat = -3.184416865734681;
  final double schoolLng = 114.53308639578164;
  final double radiusKm = 0.05; // Radius 50 meter

  // Data Foto
  var imageFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Otomatis cari lokasi saat halaman dibuka
    determinePosition();
  }

  // 1. Cek Izin & Ambil Lokasi GPS
  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    isLoading.value = true;

    // Cek GPS Nyala/Mati
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "GPS kamu mati! Nyalakan dulu.");
      isLoading.value = false;
      return;
    }

    // Cek Izin Aplikasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Error", "Izin lokasi ditolak");
        isLoading.value = false;
        return;
      }
    }

    // Ambil Koordinat
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition = position;
      
      // Hitung Jarak ke Sekolah
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude, position.longitude, schoolLat, schoolLng);
      
      if (distanceInMeters <= (radiusKm * 1000)) {
        isInArea.value = true;
        address.value = "Di dalam area sekolah (${distanceInMeters.toInt()}m)";
      } else {
        isInArea.value = false;
        address.value = "Di luar area! Jarak: ${distanceInMeters.toInt()}m";
      }

    } catch (e) {
      Get.snackbar("Error", "Gagal ambil lokasi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Ambil Foto Kamera
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 50 // Kompres biar gak berat uploadnya
    );
    if (image != null) {
      imageFile.value = File(image.path);
    }
  }

  // 3. Kirim Absen ke API
  Future<void> submitAbsen(String token) async {
    if (currentPosition == null || imageFile.value == null) {
      Get.snackbar("Error", "Foto dan Lokasi wajib ada!");
      return;
    }

    isLoading.value = true;
    
    // Gunakan MultipartRequest untuk upload file
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/absensi'));
    
    // Header Auth Token (PENTING!)
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    });

    // Data Form
    request.fields['latitude'] = currentPosition!.latitude.toString();
    request.fields['longitude'] = currentPosition!.longitude.toString();
    
    // File Foto
    request.files.add(await http.MultipartFile.fromPath('foto', imageFile.value!.path));

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 201) {
        Get.back(); // Tutup halaman absen
        Get.snackbar("Sukses", "Absensi berhasil dicatat!", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Gagal", "Error: $responseData");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal connect server");
    } finally {
      isLoading.value = false;
    }
  }
}