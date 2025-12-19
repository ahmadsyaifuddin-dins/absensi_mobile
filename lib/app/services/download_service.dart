import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class DownloadService {
  static Future<void> downloadPdf(String endpoint, Map<String, String> params) async {
    final box = GetStorage();
    String? token = box.read('token');
    
    // Tambahkan token ke query params biar backend bisa validasi (jika pakai token_query)
    params['token_query'] = token ?? '';

    // Susun Query String
    String queryString = Uri(queryParameters: params).query;
    String fullUrl = '$endpoint?$queryString';

    print("Opening PDF: $fullUrl");

    if (!await launchUrl(Uri.parse(fullUrl), mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Gagal membuka PDF / Browser tidak ditemukan");
    }
  }
}