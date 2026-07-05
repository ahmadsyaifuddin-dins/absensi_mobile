import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_config.dart';

class AdminController extends GetxController {
  var isLoading = false.obs;
  var listGuru = [].obs;

  // Form Controllers
  final namaC = TextEditingController();
  final nipC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  
  // State untuk Role
  var selectedRole = 'guru'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGuru();
  }

  // 1. FETCH DATA GURU & PEGAWAI
  Future<void> fetchGuru() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/guru'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'},
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        listGuru.value = json['data'];
      } else {
        Get.snackbar("Error", "Gagal memuat data pegawai");
      }
    } catch (e) {
      print("Error Fetch Pegawai: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. TAMBAH / UPDATE GURU & PEGAWAI
  Future<void> saveGuru({String? id}) async {
    if (namaC.text.isEmpty || nipC.text.isEmpty || emailC.text.isEmpty) {
      Get.snackbar("Error", "Semua data wajib diisi", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // Jika Mode Tambah Baru, Password Wajib
    if (id == null && passC.text.isEmpty) {
      Get.snackbar("Error", "Password wajib diisi untuk pegawai baru", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final box = GetStorage();
      var url = id == null
          ? '${ApiConfig.baseUrl}/admin/guru' // POST (Baru)
          : '${ApiConfig.baseUrl}/admin/guru/$id'; // POST (Update)

      var body = {
        'nama': namaC.text,
        'email': emailC.text,
        'nisn_nip': nipC.text,
        'role': selectedRole.value, // Tambahkan role ke API
      };

      if (passC.text.isNotEmpty) {
        body['password'] = passC.text;
      }

      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
          'Accept': 'application/json'
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Tutup Dialog/Halaman Form
        fetchGuru(); // Refresh List
        clearForm();
        Get.snackbar("Sukses", "Data Pegawai Berhasil Disimpan", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        var error = jsonDecode(response.body);
        Get.snackbar("Gagal", error['message'] ?? "Terjadi kesalahan", backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      print("Error Save: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 3. HAPUS GURU / PEGAWAI
  Future<void> deleteGuru(String id) async {
    try {
      final box = GetStorage();
      var response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/admin/guru/$id'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'},
      );

      if (response.statusCode == 200) {
        fetchGuru();
        Get.back(); // Tutup Dialog Konfirmasi
        Get.snackbar("Sukses", "Data Pegawai Dihapus", backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      print("Error Delete: $e");
    }
  }

  void clearForm() {
    namaC.clear();
    nipC.clear();
    emailC.clear();
    passC.clear();
    selectedRole.value = 'guru'; // Reset ke default
  }
}