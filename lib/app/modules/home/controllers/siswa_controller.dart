import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_config.dart';

class SiswaController extends GetxController {
  var listSiswa = [].obs;
  var listKelas = [].obs;
  var isLoading = false.obs;

  // Form Controller
  TextEditingController namaC = TextEditingController();
  TextEditingController nisnC = TextEditingController();
  TextEditingController passC = TextEditingController();
  var selectedKelasId = "".obs; // Menyimpan ID Kelas yang dipilih

  @override
  void onInit() {
    super.onInit();
    fetchSiswa();
    fetchKelas();
  }

  // 1. AMBIL DATA SISWA
  Future<void> fetchSiswa() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/siswa'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      if (response.statusCode == 200) {
        listSiswa.value = jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print("Err Siswa: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. AMBIL DATA KELAS (Dropdown)
  Future<void> fetchKelas() async {
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/data-kelas'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      if (response.statusCode == 200) {
        listKelas.value = jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print("Err Kelas: $e");
    }
  }

  // 3. SIMPAN SISWA (CREATE / UPDATE)
  Future<void> simpanSiswa({String? id}) async {
    // Validasi sederhana
    if (namaC.text.isEmpty || nisnC.text.isEmpty || selectedKelasId.value.isEmpty) {
      Get.snackbar("Error", "Nama, NISN, dan Kelas wajib diisi!", 
        backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final box = GetStorage();
      // Tentukan URL: Kalau ID null berarti CREATE, kalau ada berarti UPDATE
      String url = id == null 
          ? '${ApiConfig.baseUrl}/siswa' 
          : '${ApiConfig.baseUrl}/siswa/update/$id';

      var body = {
        'nama': namaC.text,
        'nisn_nip': nisnC.text,
        'kelas_id': selectedKelasId.value,
        'password': passC.text, // Password opsional saat edit
      };

      var response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${box.read('token')}'},
        body: body
      );

      if (response.statusCode == 200) {
        Get.back(); // Tutup Form Dialog
        Get.snackbar("Sukses", "Data siswa berhasil disimpan", 
          backgroundColor: Colors.green, colorText: Colors.white);
        fetchSiswa(); // Refresh List Siswa
        clearForm();
      } else {
        Get.snackbar("Gagal", "Mungkin NISN sudah terpakai", 
          backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      print("Err Simpan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 4. HAPUS SISWA
  Future<void> hapusSiswa(int id) async {
    try {
      final box = GetStorage();
      var response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/siswa/$id'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      if (response.statusCode == 200) {
        fetchSiswa();
        Get.snackbar("Dihapus", "Siswa berhasil dihapus");
      }
    } catch (e) {
      print("Err Hapus: $e");
    }
  }

  void clearForm() {
    namaC.clear();
    nisnC.clear();
    passC.clear();
    selectedKelasId.value = "";
  }
}