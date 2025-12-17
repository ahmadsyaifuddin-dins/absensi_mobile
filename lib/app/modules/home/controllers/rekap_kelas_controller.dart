import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_config.dart';

class RekapKelasController extends GetxController {
  var listKelas = [].obs;
  var isLoading = false.obs;
  
  TextEditingController namaKelasC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchKelas();
  }

  // 1. AMBIL DATA
  Future<void> fetchKelas() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/kelas'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );

      if (response.statusCode == 200) {
        listKelas.value = jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print("Err Kelas: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. SIMPAN (TAMBAH / EDIT)
  Future<void> simpanKelas({String? id}) async {
    if (namaKelasC.text.isEmpty) {
      Get.snackbar("Error", "Nama kelas wajib diisi!");
      return;
    }

    isLoading.value = true;
    try {
      final box = GetStorage();
      String url = id == null 
        ? '${ApiConfig.baseUrl}/kelas' 
        : '${ApiConfig.baseUrl}/kelas/update/$id';

      var response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${box.read('token')}'},
        body: {'nama_kelas': namaKelasC.text}
      );

      if (response.statusCode == 200) {
        Get.back(); // Tutup Dialog
        Get.snackbar("Sukses", "Data kelas disimpan", backgroundColor: Colors.green, colorText: Colors.white);
        fetchKelas(); // Refresh
        namaKelasC.clear();
      } else {
        Get.snackbar("Gagal", "Nama kelas mungkin sudah ada", backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal koneksi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 3. HAPUS
  Future<void> hapusKelas(int id) async {
    try {
      final box = GetStorage();
      var response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/kelas/$id'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      
      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Kelas dihapus");
        fetchKelas();
      } else {
        var msg = jsonDecode(response.body)['message'];
        Get.snackbar("Gagal", msg ?? "Gagal menghapus", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print(e);
    }
  }
}