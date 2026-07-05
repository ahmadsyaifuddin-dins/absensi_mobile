import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_config.dart';

class ApprovalController extends GetxController {
  var isLoading = false.obs;
  var listKelasPending = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchKelasPending();
  }

  // 1. Ambil data kelas, lalu saring yang statusnya 'pending'
  Future<void> fetchKelasPending() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/data-kelas'), // Pastikan endpoint ini sesuai dengan route GET kelas kamu
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
          'Accept': 'application/json'
        }
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'] as List;
        
        // Filter hanya kelas yang butuh approval (pending)
        var pendingData = data.where((kelas) => kelas['status_approval'] == 'pending').toList();
        listKelasPending.value = pendingData;
      }
    } catch (e) {
      print("Error fetch kelas pending: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Eksekusi Approve Kelas ke Laravel
  Future<void> approveKelas(String id) async {
    try {
      final box = GetStorage();
      
      // Tembak API Approve yang baru kita buat di Laravel
      var response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/kelas/approve/$id'),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
          'Accept': 'application/json'
        }
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Berhasil!", 
          "Kelas telah resmi disahkan.",
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        // Refresh daftar kelas (otomatis kelas yang di-approve akan hilang dari list)
        fetchKelasPending();
      } else {
        Get.snackbar("Gagal", "Terjadi kesalahan sistem.", backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      print("Error approve kelas: $e");
    }
  }
}