import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/api_config.dart';

class KelasSayaController extends GetxController {
  var listKelasKu = [].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKelasSaya();
  }

  Future<void> fetchKelasSaya() async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/guru/kelas-saya'),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
          'Accept': 'application/json'
        }
      );

      if (response.statusCode == 200) {
        listKelasKu.value = jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print("Err Kelas Saya: $e");
    } finally {
      isLoading.value = false;
    }
  }
}