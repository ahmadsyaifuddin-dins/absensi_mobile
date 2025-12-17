import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_config.dart';
import '../../../data/models/absensi_model.dart'; 

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
  // Kita pakai File biasa (bukan XFile) biar seragam
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
    determinePosition();      // Cari Lokasi
    fetchSettingSekolah();    // Ambil Radius/Lokasi DB
    fetchHistory();           // Ambil Riwayat
  }

  // ==========================================
  // 1. FITUR SETTING SEKOLAH (DINAMIS)
  // ==========================================
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
      print("Gagal ambil setting sekolah: $e");
    }
  }

  // ==========================================
  // 2. FITUR LOKASI
  // ==========================================
  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentPosition.value = position;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          alamat.value = "${place.street}, ${place.subLocality}";
        }
      } catch (_) {
        alamat.value = "${position.latitude}, ${position.longitude}";
      }
    } catch (e) {
      print("Error Lokasi: $e");
    }
  }

  // ==========================================
  // 3. FITUR KAMERA / GALERI
  // ==========================================
  // Parameter opsional: Default Kamera, tapi bisa dipanggil pickImage(ImageSource.gallery)
  Future<void> pickImage([ImageSource source = ImageSource.camera]) async {
    final XFile? photo = await picker.pickImage(source: source, imageQuality: 50);
    if (photo != null) {
      image.value = File(photo.path);
    }
  }

  // ==========================================
  // 4. FITUR ABSEN MASUK
  // ==========================================
  Future<void> absenMasuk(String token) async {
    if (currentPosition.value == null || image.value == null) {
      Get.snackbar("Error", "Lokasi dan Foto wajib ada!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    double jarak = Geolocator.distanceBetween(
      currentPosition.value!.latitude,
      currentPosition.value!.longitude,
      schoolLat.value,
      schoolLng.value
    );

    if (jarak > radiusMeter.value) {
       Get.snackbar("Jarak Terlalu Jauh", "Kamu berjarak ${jarak.toInt()} meter dari sekolah.\nMaksimal: ${radiusMeter.value.toInt()} meter.", backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    isLoading.value = true;
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/absensi'));
      request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});
      request.fields['latitude'] = currentPosition.value!.latitude.toString();
      request.fields['longitude'] = currentPosition.value!.longitude.toString();
      request.files.add(await http.MultipartFile.fromPath('foto', image.value!.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back();
        Get.snackbar("Sukses", "Absen Masuk Berhasil!", backgroundColor: Colors.green, colorText: Colors.white);
        fetchHistory(); // Refresh Riwayat
      } else {
        var msg = jsonDecode(responseBody)['message'] ?? "Gagal absen";
        Get.snackbar("Gagal", msg, backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal koneksi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 5. FITUR IZIN / SAKIT
  Future<void> submitIzin(String token) async {
    if (image.value == null || alasanC.text.isEmpty) {
      Get.snackbar("Error", "Foto bukti dan alasan wajib diisi!", backgroundColor: Colors.red, colorText: Colors.white);
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
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back();
        Get.snackbar("Sukses", "Izin berhasil diajukan", backgroundColor: Colors.green, colorText: Colors.white);
        fetchHistory();
      } else {
        var msg = jsonDecode(responseBody)['message'] ?? "Gagal izin";
        Get.snackbar("Gagal", msg, backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal koneksi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 6. FITUR RIWAYAT 
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
        // Parsing ke Model Absensi
        historyList.value = data.map((e) => Absensi.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error history: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }
}