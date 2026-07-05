import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_config.dart';

class SekolahController extends GetxController {
  var isLoading = false.obs;
 
  // Controller Text Field
  TextEditingController namaSekolahC = TextEditingController();
  TextEditingController jamMasukC = TextEditingController();
  TextEditingController latC = TextEditingController();
  TextEditingController longC = TextEditingController();
  TextEditingController radiusC = TextEditingController();
  
  // [BARU] Controller Fonnte
  TextEditingController fonnteTokenC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchSekolah();
  }

  // 1. AMBIL DATA DARI SERVER
  Future<void> fetchSekolah() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/sekolah'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
       
        if (data != null) {
          namaSekolahC.text = data['nama_sekolah'] ?? '';
          
          String jam = data['jam_masuk'] ?? '07:30';
          jamMasukC.text = jam.length > 5 ? jam.substring(0, 5) : jam;
         
          latC.text = data['latitude'].toString();
          longC.text = data['longitude'].toString();
          radiusC.text = data['radius_meter'].toString();
          
          // [BARU] Isi form Fonnte Token dari database
          fonnteTokenC.text = data['fonnte_token'] ?? ''; 
        }
      }
    } catch (e) {
      print("Error Sekolah: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. FUNGSI MEMILIH JAM (Time Picker)
  Future<void> selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay(hour: 7, minute: 30);
   
    if (jamMasukC.text.isNotEmpty && jamMasukC.text.contains(':')) {
      var parts = jamMasukC.text.split(':');
      initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedHour = picked.hour.toString().padLeft(2, '0');
      final String formattedMinute = picked.minute.toString().padLeft(2, '0');
      jamMasukC.text = "$formattedHour:$formattedMinute";
    }
  }

  // 3. SIMPAN DATA
  Future<void> simpanPengaturan() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/sekolah/update'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'},
        body: {
          'nama_sekolah': namaSekolahC.text,
          'jam_masuk': jamMasukC.text, 
          'latitude': latC.text,
          'longitude': longC.text,
          'radius_meter': radiusC.text,
          
          // [BARU] Kirim Fonnte Token ke backend saat disimpan
          'fonnte_token': fonnteTokenC.text,
        }
      );

      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Pengaturan Sekolah Disimpan!",
          backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Gagal", "Cek inputan anda");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal koneksi: $e");
    } finally {
      isLoading.value = false;
    }
  }
}