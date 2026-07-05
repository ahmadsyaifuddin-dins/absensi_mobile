import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Wajib untuk format tanggal
import '../../../data/providers/api_config.dart';

// Import Services Baru
import '../../../services/laporan_service.dart';
import '../../../services/download_service.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class LaporanController extends GetxController {
  var isLoading = false.obs;

  // --- DATA HOLDER ---
  var listHarian = [].obs;
  var listPengajuan = [].obs;
  var listTelat = [].obs;
  var listKelas = [].obs;
  var listBulanan = [].obs;
  var listSiswaDropdown = [].obs;
  var listDetailSiswa = [].obs;
  var listRekapIzin = [].obs;
  var listGuruMatpel = [].obs;
  var selectedGuruMatpelId = "".obs;
  var selectedDateMatpel = DateTime.now().obs;
  
  // --- FILTER VARIABLES ---
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  var selectedDate = DateTime.now().obs;
  var selectedDateJarak = DateTime.now().obs; // Tambahan untuk GPS

  var selectedKelasId = "".obs;
  var selectedSiswaId = "".obs;
  var selectedKategoriIzin = 'Semua'.obs;
  
  var hasSearched = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKelas();
    fetchListGuruMatpel();
  }

  // =========================================================
  // LOGIC FETCH DATA (PANGGIL SERVICE)
  // =========================================================

  Future<void> fetchKelas() async {
    try {
      var data = await LaporanService.getKelas();
      listKelas.value = data;
      
      // Auto-select kelas pertama
      if (listKelas.isNotEmpty) {
        selectedKelasId.value = listKelas[0]['id'].toString();
        fetchSiswaByKelas();
      }
    } catch (e) {
      print("Err Kelas: $e");
    }
  }

  Future<void> fetchLaporanHarian() async {
    if (selectedKelasId.value.isEmpty) return;
    isLoading.value = true;
    try {
      String tgl = selectedDate.value.toString().split(' ')[0];
      listHarian.value = await LaporanService.getHarian(selectedKelasId.value, tgl);
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLaporanBulanan() async {
    if (selectedKelasId.value.isEmpty) return;
    isLoading.value = true;
    try {
      listBulanan.value = await LaporanService.getBulanan(
        selectedKelasId.value, 
        selectedMonth.value, 
        selectedYear.value
      );
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPengajuanIzin() async {
    isLoading.value = true;
    try {
      listPengajuan.value = await LaporanService.getPengajuanIzin();
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifikasiIzin(int id, String aksi) async {
    try {
      await LaporanService.verifikasiIzin(id, aksi);
      Get.snackbar("Sukses", "Izin berhasil $aksi", backgroundColor: Colors.green, colorText: Colors.white);
      fetchPengajuanIzin(); // Refresh
    } catch (e) {
      Get.snackbar("Error", "$e", backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> fetchSiswaByKelas() async {
    if (selectedKelasId.value.isEmpty) return;
    try {
      listSiswaDropdown.value = await LaporanService.getSiswaByKelas(selectedKelasId.value);
      if (listSiswaDropdown.isNotEmpty) {
        selectedSiswaId.value = listSiswaDropdown[0]['id'].toString();
      } else {
        selectedSiswaId.value = "";
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchLaporanSiswa() async {
    if (selectedSiswaId.value.isEmpty) {
      Get.snackbar("Error", "Pilih siswa terlebih dahulu");
      return;
    }
    isLoading.value = true;
    hasSearched.value = true;
    try {
      listDetailSiswa.value = await LaporanService.getDetailSiswa(selectedSiswaId.value);
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRekapTelat() async {
    isLoading.value = true;
    try {
      listTelat.value = await LaporanService.getRekapTelat(selectedMonth.value, selectedYear.value);
    } catch (e) { print(e); } finally { isLoading.value = false; }
  }

  Future<void> fetchRekapIzin() async {
    isLoading.value = true;
    try {
      listRekapIzin.value = await LaporanService.getRekapIzin(
        selectedMonth.value, 
        selectedYear.value, 
        selectedKategoriIzin.value
      );
    } catch (e) { print(e); } finally { isLoading.value = false; }
  }

  // =========================================================
  // LOGIC DOWNLOAD PDF (PANGGIL DOWNLOAD SERVICE)
  // =========================================================

  void downloadPdf() {
    if (selectedKelasId.value.isEmpty) return;
    String tgl = selectedDate.value.toString().split(' ')[0];
    
    DownloadService.downloadPdf('${ApiConfig.baseUrl}/laporan/harian/export', {
      'kelas_id': selectedKelasId.value,
      'tanggal': tgl,
    });
  }

  void downloadPdfBulanan() {
    if (selectedKelasId.value.isEmpty) return;
    
    DownloadService.downloadPdf('${ApiConfig.baseUrl}/laporan/bulanan/export', {
      'kelas_id': selectedKelasId.value,
      'bulan': selectedMonth.value.toString(),
      'tahun': selectedYear.value.toString(),
    });
  }

  void downloadPdfSiswa() {
    if (selectedSiswaId.value.isEmpty) return;
    
    DownloadService.downloadPdf('${ApiConfig.baseUrl}/laporan/siswa/export', {
      'user_id': selectedSiswaId.value,
      'bulan': selectedMonth.value.toString(),
      'tahun': selectedYear.value.toString(),
    });
  }

  void downloadPdfTelat() {
    DownloadService.downloadPdf('${ApiConfig.baseUrl}/laporan/telat/export', {
      'bulan': selectedMonth.value.toString(),
      'tahun': selectedYear.value.toString(),
    });
  }

  void downloadPdfRekapIzin() {
    DownloadService.downloadPdf('${ApiConfig.baseUrl}/laporan/izin/export', {
      'bulan': selectedMonth.value.toString(),
      'tahun': selectedYear.value.toString(),
      'kategori': selectedKategoriIzin.value,
    });
  }

  // =========================================================
  // LOGIC LAPORAN JARAK (GPS)
  // =========================================================

  Future<void> chooseDateJarak(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateJarak.value,
      firstDate: DateTime(2024), 
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, 
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDateJarak.value = picked;
    }
  }

  void downloadPdfJarak() {
    if (selectedKelasId.value.isEmpty) {
      Get.snackbar(
        "Peringatan", 
        "Silakan pilih kelas terlebih dahulu!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Format tanggal jadi YYYY-MM-DD
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDateJarak.value);
    
    // Pakai DownloadService bawaan aplikasimu! Lebih rapi.
    DownloadService.downloadPdf('${ApiConfig.baseUrl}/laporan/jarak/export', {
      'kelas_id': selectedKelasId.value,
      'tanggal': formattedDate,
    });
  }

  // =========================================================
  // LOGIC LAPORAN RED FLAG (SISWA BERMASALAH)
  // =========================================================

  void downloadPdfRedFlag() {
    // Kita tinggal lempar bulan dan tahun ke route backend yang baru kita buat
    DownloadService.downloadPdf('${ApiConfig.baseUrl}/laporan/redflag/export', {
      'bulan': selectedMonth.value.toString(),
      'tahun': selectedYear.value.toString(),
    });
  }

  // =========================================================
  // LOGIC LAPORAN PERSENTASE KEHADIRAN KELAS
  // =========================================================

  void downloadPdfPersentase() {
    DownloadService.downloadPdf('${ApiConfig.baseUrl}/laporan/persentase/export', {
      'bulan': selectedMonth.value.toString(),
      'tahun': selectedYear.value.toString(),
    });
  }

  // =========================================================
  // LOGIC LAPORAN PRESENSI MATPEL
  // =========================================================

  // 1. Ambil Data Guru untuk Dropdown Laporan Matpel
  Future<void> fetchListGuruMatpel() async {
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/list-guru-matpel'),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        listGuruMatpel.value = data['data'];
        
        if (listGuruMatpel.isNotEmpty) {
          selectedGuruMatpelId.value = listGuruMatpel[0]['id'].toString();
        }
      }
    } catch (e) {
      print("Error fetch list guru matpel: $e");
    }
  }

  // 2. Pemilih Tanggal
  Future<void> chooseDateMatpel(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateMatpel.value,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.cyan[700]!, // Sesuaikan warna dengan tema laporan
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDateMatpel.value = picked;
    }
  }

  // 3. Eksekusi Download PDF
  void downloadPdfMatpel() {
    if (selectedKelasId.value.isEmpty || selectedGuruMatpelId.value.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Silakan pilih Kelas dan Guru terlebih dahulu!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Format tanggal jadi YYYY-MM-DD
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDateMatpel.value);
    
    DownloadService.downloadPdf('${ApiConfig.baseUrl}/laporan/matpel/export', {
      'kelas_id': selectedKelasId.value,
      'guru_id': selectedGuruMatpelId.value,
      'tanggal': formattedDate,
    });
  }

  // =========================================================
  // LOGIC GRAFIK PERSENTASE (KEPSEK)
  // =========================================================

  // State untuk menampung persentase kehadiran
  var pctHadir = 0.0.obs;
  var pctSakit = 0.0.obs;
  var pctIzin = 0.0.obs;
  var pctAlpa = 0.0.obs;

  Future<void> fetchDataGrafik() async {
    isLoading.value = true;
    try {
      // Nanti kamu bisa ubah ini dengan hit API ke backend Laravel
      // Contoh: var response = await http.get('${ApiConfig.baseUrl}/laporan/persentase-chart');
      
      // --- DUMMY DATA SEMENTARA ---
      // Agar grafiknya bisa langsung kamu lihat hasilnya saat di-build
      await Future.delayed(Duration(milliseconds: 800)); // Simulasi loading API
      pctHadir.value = 65.0; // 65% Hadir
      pctSakit.value = 15.0; // 15% Sakit
      pctIzin.value = 10.0;  // 10% Izin
      pctAlpa.value = 10.0;  // 10% Alpa/Bolos
      
    } catch (e) {
      print("Error fetch grafik: $e");
    } finally {
      isLoading.value = false;
    }
  }
}