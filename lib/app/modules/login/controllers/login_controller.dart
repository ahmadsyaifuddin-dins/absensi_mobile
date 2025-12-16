import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/providers/api_config.dart';
import '../../home/views/home_view.dart'; // Dashboard SISWA
import '../../home/views/guru_dashboard_view.dart'; // Dashboard GURU (File Baru)
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final idC = TextEditingController();
  final passC = TextEditingController();

  var isLoading = false.obs;

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

        // --- LOGIC BARU DIMULAI DI SINI ---

        final box = GetStorage();
        box.write('token', token);
        box.write('user', userData);

        // 1. Simpan Role secara spesifik biar nanti Main.dart gampang ngecek
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
          // 2. Cek Role untuk Mengarahkan Halaman
          if (role == 'guru' || role == 'admin') {
            // Kalau Guru -> Ke Dashboard Guru
            Get.offAll(() => GuruDashboardView());
          } else {
            // Kalau Siswa -> Ke Dashboard Siswa (HomeView)
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
