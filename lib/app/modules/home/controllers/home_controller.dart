import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../login/views/login_view.dart';

class HomeController extends GetxController {
  // Variable User biar reactive
  var user = {}.obs;

  @override
  void onInit() {
    super.onInit();
    // Saat Controller dibuat (termasuk habis refresh), BACA ULANG STORAGE
    final box = GetStorage();
    if (box.hasData('user')) {
      user.value = box.read('user');
    }
  }

  void logout() {
    final box = GetStorage();
    box.erase(); // Hapus semua data
    Get.offAll(() => LoginView());
  }
}
