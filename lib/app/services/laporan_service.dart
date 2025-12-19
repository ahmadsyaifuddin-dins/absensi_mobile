import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../data/providers/api_config.dart';

class LaporanService {
  static final box = GetStorage();

  // Helper Headers
  static Map<String, String> get _headers {
    String? token = box.read('token');
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  // 1. DATA KELAS
  static Future<List> getKelas() async {
    var response = await http.get(Uri.parse('${ApiConfig.baseUrl}/data-kelas'), headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw "Gagal memuat kelas";
  }

  // 2. LAPORAN HARIAN
  static Future<List> getHarian(String kelasId, String tanggal) async {
    var response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/laporan/harian?kelas_id=$kelasId&tanggal=$tanggal'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw "Gagal memuat laporan harian";
  }

  // 3. LAPORAN BULANAN
  static Future<List> getBulanan(String kelasId, int bulan, int tahun) async {
    var response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/laporan/bulanan?kelas_id=$kelasId&bulan=$bulan&tahun=$tahun'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw "Gagal memuat laporan bulanan";
  }

  // 4. PENGAJUAN IZIN
  static Future<List> getPengajuanIzin() async {
    var response = await http.get(Uri.parse('${ApiConfig.baseUrl}/laporan/pengajuan-izin'), headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw "Gagal memuat pengajuan izin";
  }

  static Future<void> verifikasiIzin(int id, String aksi) async {
    var response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/laporan/verifikasi-izin'),
      headers: _headers,
      body: {'absensi_id': id.toString(), 'aksi': aksi},
    );
    if (response.statusCode != 200) throw "Gagal update status";
  }

  // 5. SISWA BY KELAS
  static Future<List> getSiswaByKelas(String kelasId) async {
    var response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/list-siswa-by-kelas?kelas_id=$kelasId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }

  // 6. DETAIL SISWA
  static Future<List> getDetailSiswa(String userId) async {
    var response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/laporan/siswa?user_id=$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw "Gagal memuat detail siswa";
  }

  // 7. REKAP TELAT
  static Future<List> getRekapTelat(int bulan, int tahun) async {
    var response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/laporan/telat?bulan=$bulan&tahun=$tahun'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw "Gagal memuat rekap telat";
  }

  // 8. REKAP IZIN (HISTORY)
  static Future<List> getRekapIzin(int bulan, int tahun, String kategori) async {
    String url = '${ApiConfig.baseUrl}/laporan/rekap-izin?bulan=$bulan&tahun=$tahun&kategori=$kategori';
    var response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw "Gagal memuat rekap izin";
  }
}