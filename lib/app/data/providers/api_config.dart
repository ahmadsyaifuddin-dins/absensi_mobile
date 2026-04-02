class ApiConfig {
  // Ganti IP ini sesuai IP Laptop kamu saat ini
  static const String mainUrl = "http://192.168.1.50:8000"; 
  
  // URL untuk API
  static const String baseUrl = "$mainUrl/api";
  
  // Karena sekarang filenya ada di: root/public/absensi
  static const String imageUrl = "$mainUrl/";}