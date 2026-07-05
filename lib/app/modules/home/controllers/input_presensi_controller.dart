import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_config.dart';

class InputPresensiController extends GetxController {
  var isLoading = false.obs;
  var isFetchingSiswa = false.obs;
  
  var listKelas = [].obs;
  var listSiswa = [].obs;
  
  var selectedKelasId = "".obs;
  TextEditingController matpelC = TextEditingController();

  // Map untuk menyimpan status tiap siswa { id_siswa : 'Hadir' }
  var statusPresensi = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKelas();
  }

  // 1. Ambil daftar kelas untuk Dropdown
  Future<void> fetchKelas() async {
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
    }
  }

  // 2. Ambil daftar siswa saat kelas dipilih
  Future<void> fetchSiswaByKelas(String kelasId) async {
    isFetchingSiswa.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/siswa?kelas_id=$kelasId'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      
      if (response.statusCode == 200) {
        listSiswa.value = jsonDecode(response.body)['data'];
        
        // Auto-set semua siswa jadi 'Hadir' biar guru gak capek ngeklik satu-satu
        statusPresensi.clear();
        for (var siswa in listSiswa) {
          statusPresensi[siswa['id']] = 'Hadir';
        }
      }
    } catch (e) {
      print("Err Siswa: $e");
    } finally {
      isFetchingSiswa.value = false;
    }
  }

  // 3. Update status per siswa saat guru ngeklik tombol
  void updateStatus(int siswaId, String status) {
    statusPresensi[siswaId] = status;
  }

  // 4. Submit Bulk Insert ke Laravel
  Future<void> submitPresensi() async {
    if (selectedKelasId.value.isEmpty || matpelC.text.isEmpty) {
      Get.snackbar("Peringatan", "Pilih Kelas dan Isi Nama Mata Pelajaran!", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (listSiswa.isEmpty) {
      Get.snackbar("Peringatan", "Tidak ada data siswa di kelas ini.", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final box = GetStorage();
      
      // Format data menjadi array of objects sesuai request Laravel
      List<Map<String, dynamic>> absensiArray = [];
      statusPresensi.forEach((siswaId, status) {
        absensiArray.add({
          'pengguna_id': siswaId,
          'status': status
        });
      });

      var body = jsonEncode({
        'kelas_id': selectedKelasId.value,
        'matpel': matpelC.text,
        'absensi': absensiArray
      });

      var response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/presensi-matpel/bulk'),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
          'Content-Type': 'application/json', // Wajib diset karena kirim raw JSON
          'Accept': 'application/json'
        },
        body: body
      );

      if (response.statusCode == 200) {
        Get.back(); // Kembali ke halaman sebelumnya
        Get.snackbar("Sukses", "Presensi kelas berhasil disimpan!", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Gagal", "Terjadi kesalahan server.", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("Err Submit Matpel: $e");
    } finally {
      isLoading.value = false;
    }
  }
}