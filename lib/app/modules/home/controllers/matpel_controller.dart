import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_config.dart';

class MatpelController extends GetxController {
  var isLoadingRiwayat = false.obs;
  var riwayatSiswaMatpel = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRiwayatMatpelGuru(); 
  }

  // ==========================================
  // [GURU] Lihat Riwayat Presensi Kelasnya
  // ==========================================
  Future<void> fetchRiwayatMatpelGuru({String? tanggal}) async {
    try {
      isLoadingRiwayat.value = true;
      final box = GetStorage();
      
      // Mengarah ke route API yang baru kita buat
      String url = '${ApiConfig.baseUrl}/presensi-matpel/riwayat';
      if (tanggal != null) {
        url += '?tanggal=$tanggal';
      }

      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        riwayatSiswaMatpel.value = data['data'];
      }
    } catch (e) {
      print("Error fetch riwayat guru matpel: $e");
    } finally {
      isLoadingRiwayat.value = false;
    }
  }
}