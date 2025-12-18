import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/providers/api_config.dart';
import '../../home/views/home_view.dart'; // Dashboard SISWA
import '../../home/views/guru/guru_dashboard_view.dart'; // Dashboard GURU
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final idC = TextEditingController();
  final passC = TextEditingController();

  var isLoading = false.obs;

  // Untuk menyimpan nama sekolah
  var namaSekolah = "Absensi Sekolah".obs; 

  // Jalan otomatis saat halaman dibuka
  @override
  void onInit() {
    super.onInit();
    getNamaSekolah(); // Panggil fungsi ambil nama sekolah
  }

  // Ambil Nama Sekolah dari API (Public)
  Future<void> getNamaSekolah() async {
    try {
      // Tidak perlu token karena route /sekolah sudah kita buat Public di api.php
      var response = await http.get(Uri.parse('${ApiConfig.baseUrl}/sekolah'));
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        if (data != null) {
          // Update variable namaSekolah biar UI berubah
          namaSekolah.value = data['nama_sekolah'] ?? "Absensi Sekolah";
        }
      }
    } catch (e) {
      print("Gagal muat nama sekolah: $e");
      // Kalau gagal (misal server mati), biarkan default
    }
  }

  // 4. FUNGSI LOGIN
  Future<void> login() async {
    if (idC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar(
        "Error",
        "NISN/NIP dan Password wajib diisi!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {'Accept': 'application/json'},
        body: {'login_id': idC.text, 'password': passC.text},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var userData = data['data']['user'];
        var token = data['data']['access_token'];

        // --- SIMPAN DATA KE STORAGE ---
        final box = GetStorage();
        box.write('token', token);
        box.write('user', userData);

        // Simpan Role
        String role = userData['role'];
        box.write('role', role);

        print("Login Sukses: ${userData['nama']} sebagai $role");

        Get.snackbar(
          "Berhasil",
          "Login sebagai $role",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Future.delayed(Duration(seconds: 1), () {
          // Cek Role untuk Mengarahkan Halaman
          if (role == 'guru' || role == 'admin') {
            Get.offAll(() => GuruDashboardView());
          } else {
            Get.offAll(() => HomeView());
          }
        });
      } else {
        var errorData = jsonDecode(response.body);
        Get.snackbar(
          "Gagal Login",
          errorData['message'] ?? "Cek NISN/Password",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("ERROR: $e");
      Get.snackbar(
        "Error",
        "Gagal connect server. Cek IP Address!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}