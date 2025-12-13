import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/providers/api_config.dart';
import '../../home/views/home_view.dart'; 
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  // Controller untuk Text Input
  final idC = TextEditingController();
  final passC = TextEditingController();

  // Variable Loading
  var isLoading = false.obs;

  Future<void> login() async {
    // 1. Validasi Input Kosong
    if (idC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar("Error", "NISN/NIP dan Password wajib diisi!",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // 2. Mulai Loading
    isLoading.value = true;

    try {
      // 3. Tembak API Laravel
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {'Accept': 'application/json'},
        body: {
          'login_id': idC.text, // Sudah benar pakai login_id
          'password': passC.text,
        },
      );

      // 4. Cek Respon
      if (response.statusCode == 200) {
        // SUKSES
        var data = jsonDecode(response.body);
        var userData = data['data']['user']; // Ambil objek user lengkap
        var token = data['data']['access_token'];

        final box = GetStorage();
        box.write('token', token); // Simpan Token
        box.write('user', userData); // Simpan Data User (Nama, Kelas, dll)
        
        print("DATA TERSIMPAN: Token & User aman.");
        Get.snackbar("Berhasil", "Selamat datang, ${userData['nama']}",
            backgroundColor: Colors.green, colorText: Colors.white);
        
        // Delay dikit biar snackbar kebaca, baru pindah
        Future.delayed(Duration(seconds: 1), () {
           // Pindah ke Home sambil bawa oleh-oleh (userData)
        Get.offAll(() => HomeView());
        });

      } else {
        // GAGAL
        var errorData = jsonDecode(response.body);
        Get.snackbar("Gagal Login", errorData['message'] ?? "Terjadi Kesalahan",
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      // ERROR JARINGAN
      print("ERROR: $e");
      Get.snackbar("Error", "Tidak dapat terhubung ke server. Cek IP Address!",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      // 5. Stop Loading
      isLoading.value = false;
    }
  }
}