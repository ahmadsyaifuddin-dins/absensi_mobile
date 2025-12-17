import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../data/providers/api_config.dart';
import '../../login/views/login_view.dart';

class HomeController extends GetxController {
  final box = GetStorage();
  // Variable User biar reactive
  var user = {}.obs;

  var sudahAbsen = false.obs; // Status absen
  var namaKelas = "-".obs;    // Nama Kelas

  @override
  void onInit() {
    super.onInit();
    // Load data user local
    if (box.hasData('user')) {
      user.value = box.read('user');
    }
    // Cek Status Absen & Kelas ke Server
    checkStatusToday();
  }

  Future<void> checkStatusToday() async {
    try {
      String? token = box.read('token');
      if (token == null) return;

      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/absensi/check-today'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        }
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        
        // Update Variable UI
        sudahAbsen.value = data['sudah_absen'];
        namaKelas.value = data['nama_kelas'];
        
        // (Optional) Update data user lokal kalau mau simpan kelas
        // tapi pakai variable observable aja udah cukup
      }
    } catch (e) {
      print("Error Check Status: $e");
    }
  }

  void logout() {
    final box = GetStorage();
    box.erase(); // Hapus semua data
    Get.offAll(() => LoginView());
  }
}
