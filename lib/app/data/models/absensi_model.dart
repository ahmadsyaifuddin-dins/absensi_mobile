class Absensi {
  int? id;
  String? tanggal;
  String? jamMasuk;
  String? status;     // Hadir, Izin, Sakit
  String? fotoMasuk;  // Path foto (absensi/xxx.jpg)
  bool? terlambat;
  int? menitKeterlambatan;

  Absensi({
    this.id,
    this.tanggal,
    this.jamMasuk,
    this.status,
    this.fotoMasuk,
    this.terlambat,
    this.menitKeterlambatan,
  });

  // Fungsi mengubah JSON dari Laravel menjadi Object Flutter
  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      id: json['id'],
      tanggal: json['tanggal'],
      jamMasuk: json['jam_masuk'], // Sesuaikan nama kolom di DB
      status: json['status'],
      fotoMasuk: json['foto_masuk'],
      terlambat: json['terlambat'] == 1 || json['terlambat'] == true,
      menitKeterlambatan: json['menit_keterlambatan'],
    );
  }
}