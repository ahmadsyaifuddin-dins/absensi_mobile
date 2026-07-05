import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

import '../../../data/providers/api_config.dart';

class MatpelController extends GetxController {
  // State untuk Siswa
  var isLoading = false.obs;
  var listGuru = [].obs;
  var selectedGuruId = Rxn<int>();

  // State untuk Guru Matpel
  var isLoadingRiwayat = false.obs;
  var riwayatSiswaMatpel = [].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Otomatis deteksi Role saat controller dipanggil
    final box = GetStorage();
    String? role = box.read('role');
    
    if (role == 'siswa') {
      fetchListGuru(); // Siapkan dropdown guru buat siswa
    } else if (role == 'guru') {
      fetchRiwayatMatpelGuru(); // Siapkan list siswa masuk kelas buat guru
    }
  }

  // ==========================================
  // 1. [SISWA] Ambil Daftar Guru untuk Dropdown
  // ==========================================
  Future<void> fetchListGuru() async {
    try {
      isLoading.value = true;
      final box = GetStorage();
      String? token = box.read('token');

      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/list-guru-matpel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        listGuru.value = data['data'];
      }
    } catch (e) {
      print("Error fetch list guru: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // 2. [SISWA] Submit Presensi Mata Pelajaran
  // ==========================================
  Future<void> submitAbsenMatpel() async {
    if (selectedGuruId.value == null) {
      Get.snackbar(
        "Peringatan", "Pilih Guru Mata Pelajaran terlebih dahulu!",
        backgroundColor: Colors.redAccent, colorText: Colors.white
      );
      return;
    }

    try {
      isLoading.value = true;
      final box = GetStorage();
      String? token = box.read('token');

      var response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/absensi-matpel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
        body: {
          'guru_id': selectedGuruId.value.toString(),
        }
      );

      var responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Tutup halaman
        Get.snackbar(
          "Berhasil!", responseBody['message'] ?? "Presensi kelas tercatat.",
          backgroundColor: Colors.green, colorText: Colors.white
        );
      } else {
        Get.snackbar(
          "Gagal", responseBody['message'] ?? "Terjadi kesalahan sistem.",
          backgroundColor: Colors.orange, colorText: Colors.white
        );
      }
    } catch (e) {
      print("Error submit matpel: $e");
      Get.snackbar(
        "Error", "Gagal menghubungi server.",
        backgroundColor: Colors.red, colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // 3. [GURU] Lihat Riwayat Siswa di Kelasnya
  // ==========================================
  Future<void> fetchRiwayatMatpelGuru({String? tanggal}) async {
    try {
      isLoadingRiwayat.value = true;
      final box = GetStorage();
      String? token = box.read('token');

      // Jika variabel 'tanggal' null, API backend otomatis mengambil hari ini
      String url = '${ApiConfig.baseUrl}/guru/riwayat-matpel';
      if (tanggal != null) {
        url += '?tanggal=$tanggal';
      }

      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        riwayatSiswaMatpel.value = data['data'];
      }
    } catch (e) {
      print("Error fetch riwayat guru matpel: $e");
    } finally {
      isLoadingRiwayat.value = false;
    }
  }
}