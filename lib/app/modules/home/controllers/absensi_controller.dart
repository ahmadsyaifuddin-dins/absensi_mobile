import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

// Import Service & Model
import '../../../data/providers/api_config.dart';
import '../../../data/models/absensi_model.dart';
import '../../../services/security_service.dart';
import '../../../services/location_service.dart';

class AbsensiController extends GetxController {
  var isLoading = false.obs;
  var isLoadingHistory = false.obs;

  // --- DATA LOKASI & SEKOLAH ---
  var currentPosition = Rxn<Position>();
  var alamat = "-".obs;
  
  // Default Koordinat (Nanti ditimpa fetchSettingSekolah)
  var schoolLat = (-3.18441686).obs;
  var schoolLng = (114.53308639).obs;
  var radiusMeter = (50.0).obs;

  // --- DATA FOTO ---
  var image = Rxn<File>(); 
  final ImagePicker picker = ImagePicker();

  // --- DATA IZIN ---
  var kategoriIzin = 'Sakit'.obs;
  TextEditingController alasanC = TextEditingController();

  // --- DATA RIWAYAT ---
  var historyList = <Absensi>[].obs;

  @override
  void onInit() {
    super.onInit();
    updateLocation();         // Cari Lokasi Awal (Refactored)
    fetchSettingSekolah();    // Ambil Radius/Lokasi DB
    fetchHistory();           // Ambil Riwayat
  }

  // ==========================================
  // 1. UPDATE LOKASI (Panggil LocationService)
  // ==========================================
  Future<void> updateLocation() async {
    try {
      // Panggil Service Location
      Position pos = await LocationService.getCurrentPosition();
      currentPosition.value = pos;
      
      // Ambil Alamat
      alamat.value = await LocationService.getAddressFromCoordinates(pos.latitude, pos.longitude);
      
    } catch (e) {
      // Error handling UI disini
      print("Error Lokasi: $e"); // Boleh diprint atau snackbar kalau perlu
    }
  }

  // ==========================================
  // 2. ABSEN MASUK (CLEAN VERSION)
  // ==========================================
  Future<void> absenMasuk(String token) async {
    // A. Validasi Foto
    if (image.value == null) {
      Get.snackbar("Error", "Wajib selfie dulu!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      // --- [LAYER 1] SECURITY CHECK (Strict) ---
      // Panggil SecurityService. Jika ada violation, dia akan throw Error.
      await SecurityService.checkDeviceIntegrity();

      // --- [LAYER 2] REFRESH LOKASI ---
      // Paksa ambil lokasi terbaru saat tombol ditekan
      await updateLocation();
      
      if (currentPosition.value == null) {
        throw "Gagal mendapatkan lokasi terkini. Coba lagi.";
      }

      // --- [LAYER 3] CEK MOCK LOCATION (Fake GPS) ---
      // Tidak ada bypass developer lagi. Semua kena.
      if (currentPosition.value!.isMocked) {
        Get.snackbar(
          "PERINGATAN KERAS! 🚨", 
          "Terdeteksi FAKE GPS! Sistem menolak lokasi palsu.",
          backgroundColor: Colors.red[900],
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          icon: Icon(Icons.warning, color: Colors.yellow, size: 30),
        );
        isLoading.value = false;
        return;
      }

      // --- [LAYER 4] CEK RADIUS JARAK ---
      double jarak = LocationService.getDistance(
        currentPosition.value!.latitude,
        currentPosition.value!.longitude,
        schoolLat.value,
        schoolLng.value
      );

      if (jarak > radiusMeter.value) {
         throw "Jarak Terlalu Jauh! Kamu berjarak ${jarak.toInt()}m. (Maks: ${radiusMeter.value.toInt()}m)";
      }

      // --- [LAYER 5] KIRIM KE SERVER ---
      await _postAbsenMasuk(token);

    } catch (e) {
      // Tangkap Error dari Service (String error message)
      Get.snackbar("Gagal Absen", e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // 3. LOGIC POST API (Private Method biar rapi)
  // ==========================================
  Future<void> _postAbsenMasuk(String token) async {
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/absensi'));
    request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    
    request.fields['latitude'] = currentPosition.value!.latitude.toString();
    request.fields['longitude'] = currentPosition.value!.longitude.toString();
    request.files.add(await http.MultipartFile.fromPath('foto', image.value!.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201 || response.statusCode == 200) {
      Get.back(); // Tutup Dialog/Halaman
      Get.snackbar("Sukses", "Absen Masuk Berhasil!", backgroundColor: Colors.green, colorText: Colors.white);
      fetchHistory(); // Refresh Riwayat
    } else {
      var msg = jsonDecode(responseBody)['message'] ?? "Gagal absen";
      throw msg; // Lempar ke catch di atas
    }
  }

  // ==========================================
  // 4. API & LAINNYA (Tetap Sama)
  // ==========================================
  
  Future<void> pickImage([ImageSource source = ImageSource.camera]) async {
    final XFile? photo = await picker.pickImage(source: source, imageQuality: 50);
    if (photo != null) {
      image.value = File(photo.path);
    }
  }

  Future<void> fetchSettingSekolah() async {
    try {
      var response = await http.get(Uri.parse('${ApiConfig.baseUrl}/sekolah'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        if (data != null) {
          schoolLat.value = double.parse(data['latitude'].toString());
          schoolLng.value = double.parse(data['longitude'].toString());
          radiusMeter.value = double.parse(data['radius_meter'].toString());
        }
      }
    } catch (e) {
      print("Err Sekolah: $e");
    }
  }

  Future<void> submitIzin(String token) async {
    if (image.value == null || alasanC.text.isEmpty) {
      Get.snackbar("Error", "Foto bukti & alasan wajib!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    isLoading.value = true;
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/absensi/izin'));
      request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});
      request.fields['status'] = kategoriIzin.value;
      request.fields['catatan'] = alasanC.text;
      request.files.add(await http.MultipartFile.fromPath('bukti_izin', image.value!.path));

      var response = await request.send();
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back();
        Get.snackbar("Sukses", "Izin berhasil diajukan", backgroundColor: Colors.green, colorText: Colors.white);
        fetchHistory();
      } else {
        Get.snackbar("Gagal", "Gagal mengajukan izin", backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHistory() async {
    try {
      isLoadingHistory.value = true;
      final box = GetStorage();
      String? token = box.read('token');
      if (token == null) return;

      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/riwayat-absensi'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'] as List;
        historyList.value = data.map((e) => Absensi.fromJson(e)).toList();
      }
    } catch (e) {
      print("Err history: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }
}