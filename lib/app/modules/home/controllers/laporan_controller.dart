import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LaporanController extends GetxController {
  var isLoading = false.obs;
  
  // Data Holder
  var listHarian = [].obs;
  var listPengajuan = [].obs;
  var listTelat = [].obs;
  var listKelas = [].obs;

  var listBulanan = [].obs; // Holder Data
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  
  // Filter Variables
  var selectedDate = DateTime.now().obs;
  var selectedKelasId = "".obs;

  // Variabel untuk Dropdown Siswa & Laporan Siswa (Report No. 3)
  var listSiswaDropdown = [].obs; 
  var selectedSiswaId = "".obs;   
  var listDetailSiswa = [].obs;   

  var listRekapIzin = [].obs;
  var selectedKategoriIzin = 'Semua'.obs; // Opsi: Semua, Sakit, Izin

  @override
  void onInit() {
    super.onInit();
    fetchKelas();
  }

  // 0. FETCH DATA KELAS (DROPDOWN)
  Future<void> fetchKelas() async {
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/data-kelas'), 
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      if (response.statusCode == 200) {
        listKelas.value = jsonDecode(response.body)['data'];
        
        // Auto-select kelas pertama jika ada
        if (listKelas.isNotEmpty) {
          selectedKelasId.value = listKelas[0]['id'].toString();
        }
      }
    } catch (e) {
      print("Err Kelas: $e");
    }
  }

  // --- 1. FETCH LAPORAN HARIAN ---
  Future<void> fetchLaporanHarian() async {
    if (selectedKelasId.value.isEmpty) return;
    
    isLoading.value = true;
    try {
      final box = GetStorage();
      String tgl = selectedDate.value.toString().split(' ')[0];
      
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/laporan/harian?kelas_id=${selectedKelasId.value}&tanggal=$tgl'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      
      if (response.statusCode == 200) {
        listHarian.value = jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadPdf() async {
    if (selectedKelasId.value.isEmpty) {
      Get.snackbar("Error", "Pilih kelas dulu");
      return;
    }

    final box = GetStorage();
    String token = box.read('token'); 
    String tgl = selectedDate.value.toString().split(' ')[0];

    String url = '${ApiConfig.baseUrl}/laporan/harian/export?kelas_id=${selectedKelasId.value}&tanggal=$tgl&token_query=$token';

    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Gagal membuka PDF");
    }
  }

  // --- 2. FETCH PENGAJUAN IZIN ---
  Future<void> fetchPengajuanIzin() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/laporan/pengajuan-izin'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      
      if (response.statusCode == 200) {
        listPengajuan.value = jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- 3. VERIFIKASI IZIN ---
  Future<void> verifikasiIzin(int id, String aksi) async {
    try {
      final box = GetStorage();
      var response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/laporan/verifikasi-izin'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'},
        body: {'absensi_id': id.toString(), 'aksi': aksi}
      );

      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Izin berhasil $aksi");
        fetchPengajuanIzin(); 
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  // --- 4. FETCH LAPORAN BULANAN (JSON) ---
  // (Fungsi ini sekarang SUDAH DI DALAM CLASS)
  Future<void> fetchLaporanBulanan() async {
    if (selectedKelasId.value.isEmpty) return;

    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/laporan/bulanan?kelas_id=${selectedKelasId.value}&bulan=${selectedMonth.value}&tahun=${selectedYear.value}'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );

      if (response.statusCode == 200) {
        listBulanan.value = jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- 5. DOWNLOAD PDF BULANAN ---
  Future<void> downloadPdfBulanan() async {
    if (selectedKelasId.value.isEmpty) {
      Get.snackbar("Error", "Pilih kelas dulu");
      return;
    }
    
    final box = GetStorage();
    String token = box.read('token');
    
    String url = '${ApiConfig.baseUrl}/laporan/bulanan/export?kelas_id=${selectedKelasId.value}&bulan=${selectedMonth.value}&tahun=${selectedYear.value}&token_query=$token';

    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Gagal membuka PDF");
    }
  }

  // --- 6. LOGIC DROPDOWN SISWA (Untuk Report No. 3) ---
  Future<void> fetchSiswaByKelas() async {
    if (selectedKelasId.value.isEmpty) return;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/list-siswa-by-kelas?kelas_id=${selectedKelasId.value}'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );

      if (response.statusCode == 200) {
        listSiswaDropdown.value = jsonDecode(response.body)['data'];
        if (listSiswaDropdown.isNotEmpty) {
          selectedSiswaId.value = listSiswaDropdown[0]['id'].toString();
        } else {
          selectedSiswaId.value = "";
        }
      }
    } catch (e) {
      print(e);
    }
  }

  // --- 7. FETCH DETAIL SISWA (Untuk Report No. 3) ---
  Future<void> fetchLaporanSiswa() async {
    if (selectedSiswaId.value.isEmpty) return;
    
    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/laporan/siswa?user_id=${selectedSiswaId.value}'), 
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      
      if (response.statusCode == 200) {
        listDetailSiswa.value = jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- 8. DOWNLOAD PDF SISWA (Untuk Report No. 3) ---
  Future<void> downloadPdfSiswa() async {
    if (selectedSiswaId.value.isEmpty) return;

    final box = GetStorage();
    String token = box.read('token');
    
    String url = '${ApiConfig.baseUrl}/laporan/siswa/export?user_id=${selectedSiswaId.value}&bulan=${selectedMonth.value}&tahun=${selectedYear.value}&token_query=$token';

    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Gagal membuka PDF");
    }
  }
  

  Future<void> fetchRekapTelat() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/laporan/telat?bulan=${selectedMonth.value}&tahun=${selectedYear.value}'),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      if (response.statusCode == 200) {
        listTelat.value = jsonDecode(response.body)['data'];
      }
    } catch (e) { print(e); } finally { isLoading.value = false; }
  }

  Future<void> downloadPdfTelat() async {
    final box = GetStorage();
    String token = box.read('token');
    String url = '${ApiConfig.baseUrl}/laporan/telat/export?bulan=${selectedMonth.value}&tahun=${selectedYear.value}&token_query=$token';
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) Get.snackbar("Error", "Gagal PDF");
  }

  // Fungsi Fetch Data untuk Tampilan List di HP
  Future<void> fetchRekapIzin() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      
      // Susun URL Parameter
      String url = '${ApiConfig.baseUrl}/laporan/rekap-izin?'
          'bulan=${selectedMonth.value}'
          '&tahun=${selectedYear.value}'
          '&kategori=${selectedKategoriIzin.value}'; // Filter kategori

      // Karena di View Rekap Izin tidak ada dropdown kelas, 
      // jangan kirim kelas_id yang tersimpan dari menu lain.
      
      // if (selectedKelasId.value.isNotEmpty) {
      //   url += '&kelas_id=${selectedKelasId.value}';
      // }
      // --------------------------------------------------------------

      var response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${box.read('token')}'}
      );
      
      if (response.statusCode == 200) {
        var rawData = jsonDecode(response.body)['data'] as List;
        listRekapIzin.value = rawData; 
      } else {
        listRekapIzin.clear();
      }
    } catch (e) {
      print("Error Fetch: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- 8. DOWNLOAD PDF REKAP IZIN (Perbaikan Ghost Filter) ---
  Future<void> downloadPdfRekapIzin() async {
    final box = GetStorage();
    String token = box.read('token');
    
    // HAPUS parameter '&kelas_id=...' agar semua data kelas muncul
    String url = '${ApiConfig.baseUrl}/laporan/izin/export?'
        'bulan=${selectedMonth.value}'
        '&tahun=${selectedYear.value}'
        '&kategori=${selectedKategoriIzin.value}' 
        '&token_query=$token';

    print("Download PDF URL: $url");

    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        Get.snackbar("Error", "Gagal membuka PDF");
    }
  }

}