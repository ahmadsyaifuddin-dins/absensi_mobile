import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  
  /// Meminta izin dan mengambil posisi terkini dengan akurasi tinggi.
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Coba buka settingan lokasi user otomatis
      await Geolocator.openLocationSettings();
      throw "GPS tidak aktif. Mohon aktifkan GPS.";
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw "Izin lokasi ditolak. Aplikasi butuh izin lokasi untuk absen.";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw "Izin lokasi ditolak permanen. Buka pengaturan HP untuk mengizinkan.";
    }

    // Ambil posisi High Accuracy (Penting buat deteksi Fake GPS)
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }

  /// Mengubah koordinat jadi alamat (Reverse Geocoding)
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street}, ${place.subLocality}";
      }
      return "$lat, $lng";
    } catch (_) {
      return "$lat, $lng";
    }
  }

  /// Menghitung jarak dalam meter
  static double getDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}