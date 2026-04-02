import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Wajib untuk format tanggal
import '../../../data/providers/api_config.dart';

// Import Services Baru
import '../../../services/laporan_service.dart';
import '../../../services/download_service.dart';

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
}