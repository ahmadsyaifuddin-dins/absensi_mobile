import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../data/providers/api_config.dart';
import 'package:get_storage/get_storage.dart';

class GuruController extends GetxController {
  var stats = {
    'hadir': 0,
    'izin': 0,
    'sakit': 0,
    'belum_absen': 0
  }.obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      String? token = box.read('token');
      
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/guru'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        }
      );

      // TAMBAHKAN PRINT INI UNTUK DEBUGGING
      print("STATUS CODE: ${response.statusCode}");
      print("RESPON SERVER: ${response.body}"); 
      // -------------------------------------------

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data']['statistik'];
        stats.value = {
          'hadir': data['hadir'],
          'izin': data['izin'],
          'sakit': data['sakit'],
          'belum_absen': data['belum_absen'],
        };
        } else {
        print("GAGAL FETCH: ${response.statusCode}"); // Print kalau error
      }
      
    } catch (e) {
      print("Error Guru: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void refreshData() {
    fetchDashboard();
  }
}