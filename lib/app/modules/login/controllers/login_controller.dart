import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/providers/api_config.dart';

class LoginController extends GetxController {
  // Controller untuk Text Input
  final emailC = TextEditingController();
  final passC = TextEditingController();

  // Variable Loading (Obs = Observable, biar UI bisa update otomatis)
  var isLoading = false.obs;

  Future<void> login() async {
    // 1. Validasi Input Kosong
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar("Error", "Email dan Password wajib diisi!",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // 2. Mulai Loading
    isLoading.value = true;

    try {
      // 3. Tembak API Laravel
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {'Accept': 'application/json'}, // Wajib biar Laravel tau ini API
        body: {
          'email': emailC.text,
          'password': passC.text,
        },
      );

      // 4. Cek Respon
      if (response.statusCode == 200) {
        // SUKSES
        var data = jsonDecode(response.body);
        String token = data['data']['access_token'];
        String nama = data['data']['user']['nama'];
        
        // TODO: Simpan Token ke Memory HP (Nanti kita bahas SharedPrefs)
        print("TOKEN: $token");

        Get.snackbar("Berhasil", "Selamat datang, $nama",
            backgroundColor: Colors.green, colorText: Colors.white);
        
        // Pindah ke Dashboard (Sementara kita redirect ke Home dulu)
        // Get.offAll(() => HomeView()); // Nanti diaktifkan
      } else {
        // GAGAL (Password Salah / User gak ada)
        var errorData = jsonDecode(response.body);
        Get.snackbar("Gagal Login", errorData['message'] ?? "Terjadi Kesalahan",
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      // ERROR JARINGAN / SERVER MATI
      print("ERROR: $e");
      Get.snackbar("Error", "Tidak dapat terhubung ke server. Cek IP Address!",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      // 5. Stop Loading
      isLoading.value = false;
    }
  }
}