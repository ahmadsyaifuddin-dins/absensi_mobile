import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/api_config.dart';

class HariLiburController extends GetxController {
  var isLoading = false.obs;
  var listLibur = [].obs;

  // Form Input
  final keteranganC = TextEditingController();
  var selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchLibur();
  }

  // 1. AMBIL DATA HARI LIBUR
  Future<void> fetchLibur() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/hari-libur'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'},
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        listLibur.value = json['data'];
      }
    } catch (e) {
      print("Error Fetch Libur: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. TAMBAH HARI LIBUR
  Future<void> addLibur() async {
    if (keteranganC.text.isEmpty) {
      Get.snackbar("Error", "Keterangan wajib diisi", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/hari-libur'),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
          'Accept': 'application/json'
        },
        body: {
          // Format tanggal YYYY-MM-DD
          'tanggal': DateFormat('yyyy-MM-dd').format(selectedDate.value),
          'keterangan': keteranganC.text,
        },
      );

      if (response.statusCode == 200) {
        Get.back(); // Tutup Dialog
        fetchLibur(); // Refresh List
        keteranganC.clear(); // Reset Form
        Get.snackbar("Sukses", "Hari libur berhasil ditambahkan", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        var error = jsonDecode(response.body);
        Get.snackbar("Gagal", error['message'] ?? "Gagal menyimpan", backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      print("Error Add Libur: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 3. HAPUS HARI LIBUR
  Future<void> deleteLibur(int id) async {
    try {
      final box = GetStorage();
      var response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/admin/hari-libur/$id'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'},
      );

      if (response.statusCode == 200) {
        fetchLibur();
        Get.back(); // Tutup Dialog
        Get.snackbar("Dihapus", "Hari libur dihapus", backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      print("Error Delete: $e");
    }
  }
}