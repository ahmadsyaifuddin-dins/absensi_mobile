import 'package:safe_device/safe_device.dart';

class SecurityService {
  
  /// Mengecek integritas perangkat (Root & Dev Mode).
  /// Melempar [String] error jika perangkat tidak aman.
  static Future<void> checkDeviceIntegrity() async {
    // 1. Cek Root / Jailbreak
    bool isRooted = await SafeDevice.isJailBroken;
    if (isRooted) {
      throw "HP Anda terdeteksi Rooted/Jailbreak.\nSistem menolak akses demi keamanan.";
    }

    // 2. Cek Developer Mode / USB Debugging
    // Karena bypass dimatikan, ini akan GALAK ke semua user.
    bool isDevMode = await SafeDevice.isDevelopmentModeEnable;
    if (isDevMode) {
      throw "Opsi Pengembang (Developer Options) Aktif.\nMohon matikan di Pengaturan HP untuk melakukan absensi.";
    }
    
    // 3. (Opsional) Cek Real Device
    // bool isReal = await SafeDevice.isRealDevice;
    // if (!isReal) throw "Emulator terdeteksi! Gunakan HP asli.";
  }
}