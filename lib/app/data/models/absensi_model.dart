class Absensi {
  int? id;
  int? penggunaId;
  String? tanggal;
  String? jamMasuk;
  String? jamKeluar;
  String? fotoMasuk;
  String? status;      // Hadir, Izin, Sakit, Alpa
  String? validasi;    // Pending, Diterima, Ditolak
  bool? terlambat;
  int? menitKeterlambatan;
  
  // Field Baru untuk Izin/Sakit
  String? catatan;     // Alasan izin
  String? buktiIzin;   // Foto surat dokter/bukti

  Absensi({
    this.id,
    this.penggunaId,
    this.tanggal,
    this.jamMasuk,
    this.fotoMasuk,
    this.status,
    this.validasi,
    this.terlambat,
    this.menitKeterlambatan,
    this.catatan,
    this.buktiIzin,
  });

  // Mapping dari JSON (Database) ke Flutter
  Absensi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    penggunaId = json['pengguna_id'];
    tanggal = json['tanggal'];
    jamMasuk = json['jam_masuk'];
    jamKeluar = json['jam_keluar'];
    fotoMasuk = json['foto_masuk'];
    status = json['status'];
    validasi = json['validasi'];
    
    // Handle boolean dari Laravel (kadang dikirim 1/0 atau true/false)
    if (json['terlambat'] == 1 || json['terlambat'] == true) {
      terlambat = true;
    } else {
      terlambat = false;
    }

    // Handle integer (kadang dikirim string angka)
    menitKeterlambatan = int.tryParse(json['menit_keterlambatan'].toString()) ?? 0;

    // FIELD BARU (PENTING!)
    catatan = json['catatan'];
    buktiIzin = json['bukti_izin'];
  }

  // Mapping dari Flutter ke JSON (kalau perlu kirim balik)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['pengguna_id'] = penggunaId;
    data['tanggal'] = tanggal;
    data['jam_masuk'] = jamMasuk;
    data['jam_keluar'] = jamKeluar;
    data['foto_masuk'] = fotoMasuk;
    data['status'] = status;
    data['validasi'] = validasi;
    data['terlambat'] = terlambat;
    data['menit_keterlambatan'] = menitKeterlambatan;
    data['catatan'] = catatan;
    data['bukti_izin'] = buktiIzin;
    return data;
  }
}