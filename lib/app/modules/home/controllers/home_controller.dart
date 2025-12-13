import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Import
import '../../login/views/login_view.dart'; // Import buat logout

class HomeController extends GetxController {
  RxMap<String, dynamic> user = <String, dynamic>{}.obs;
  final box = GetStorage(); // Panggil kotak penyimpanan

  @override
  void onInit() {
    super.onInit();
    
    // 1. Cek apakah ada data user di storage?
    if (box.hasData('user')) {
      // Ambil data dari storage
      user.value = box.read('user');
    }
  }

  // 2. Fungsi Logout (Hapus Session)
  void logout() {
    box.remove('token'); // Hapus token
    box.remove('user');  // Hapus data user
    
    Get.offAll(() => LoginView()); // Tendang balik ke Login
  }
}