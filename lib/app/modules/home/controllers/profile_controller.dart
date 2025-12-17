import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_config.dart';
import '../../login/views/login_view.dart'; // Buat logout

class ProfileController extends GetxController {
  var user = {}.obs;
  var isLoading = false.obs;
  
  // Controller Form Password
  TextEditingController oldPassC = TextEditingController();
  TextEditingController newPassC = TextEditingController();
  TextEditingController confirmPassC = TextEditingController();

  // Controller Form Profil
  TextEditingController namaC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Load data user dari storage saat controller dipanggil
    final box = GetStorage();
    if (box.hasData('user')) {
      user.value = box.read('user');
      namaC.text = user.value['nama'];
    }
  }

  // --- LOGOUT ---
  void logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Yakin ingin keluar?",
      textConfirm: "Ya",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () {
        final box = GetStorage();
        box.erase();
        Get.offAll(() => LoginView());
      }
    );
  }

  // --- GANTI PASSWORD ---
  Future<void> changePassword() async {
    if (newPassC.text != confirmPassC.text) {
      Get.snackbar("Error", "Konfirmasi password tidak cocok!");
      return;
    }

    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/profile/password'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'},
        body: {
          'current_password': oldPassC.text,
          'new_password': newPassC.text,
          'new_password_confirmation': confirmPassC.text,
        }
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.back(); // Tutup Dialog/Halaman
        Get.snackbar("Sukses", "Password berhasil diganti!");
        // Clear textfield
        oldPassC.clear(); newPassC.clear(); confirmPassC.clear();
      } else {
        Get.snackbar("Gagal", data['message']);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal koneksi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- UPDATE FOTO PROFIL ---
  Future<void> updateFoto() async {
    final ImagePicker picker = ImagePicker();
    // Buka Galeri
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      isLoading.value = true;
      try {
        final box = GetStorage();
        var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/profile/update'));
        request.headers.addAll({'Authorization': 'Bearer ${box.read('token')}'});
        
        request.fields['nama'] = namaC.text; // Kirim nama juga biar gak error validasi
        request.files.add(await http.MultipartFile.fromPath('foto_profil', image.path));
        
        var response = await request.send();
        var respStr = await response.stream.bytesToString();
        
        if (response.statusCode == 200) {
          var json = jsonDecode(respStr);
          // Update data di Storage biar foto langsung berubah
          box.write('user', json['data']);
          user.value = json['data']; // Update UI
          Get.snackbar("Sukses", "Foto Profil Diperbarui!");
        } else {
           Get.snackbar("Gagal", "Gagal upload foto");
        }
      } catch (e) {
         Get.snackbar("Error", "Terjadi kesalahan: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }
}