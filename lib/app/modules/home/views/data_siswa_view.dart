import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/siswa_controller.dart';
import '../../../data/providers/api_config.dart';

class DataSiswaView extends StatelessWidget {
  final controller = Get.put(SiswaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Siswa", style: GoogleFonts.poppins()),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return Center(child: CircularProgressIndicator());
        if (controller.listSiswa.isEmpty) return Center(child: Text("Belum ada data siswa."));

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: controller.listSiswa.length,
          itemBuilder: (context, index) {
            var item = controller.listSiswa[index];
            var kelas = item['kelas'] != null ? item['kelas']['nama_kelas'] : 'Tanpa Kelas';

            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple[100],
                  radius: 25,
                  // Tampilkan Foto jika ada
                  backgroundImage: item['foto_profil'] != null 
                      ? NetworkImage("${ApiConfig.imageUrl}${item['foto_profil']}") as ImageProvider
                      : null,
                  // Tampilkan Inisial jika foto kosong
                  child: item['foto_profil'] == null 
                      ? Text(
                          item['nama'][0].toUpperCase(), 
                          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)
                        )
                      : null,
                ),
                title: Text(item['nama'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text("$kelas | NISN: ${item['nisn_nip']}", style: GoogleFonts.poppins(fontSize: 12)),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') _showForm(context, item);
                    if (value == 'delete') _confirmDelete(item['id']);
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.blue), SizedBox(width: 8), Text("Edit")])),
                    PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text("Hapus")])),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showForm(context, null),
      ),
    );
  }

  // ... (Bagian Form Dialog & Delete tetap sama seperti sebelumnya) ...
  // Paste ulang fungsi _showForm dan _confirmDelete di sini kalau perlu
  
  void _showForm(BuildContext context, Map? item) {
    if (item != null) {
      controller.namaC.text = item['nama'];
      controller.nisnC.text = item['nisn_nip'];
      controller.passC.clear(); 
      controller.selectedKelasId.value = item['kelas_id'] != null ? item['kelas_id'].toString() : "";
    } else {
      controller.clearForm();
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item == null ? "Tambah Siswa" : "Edit Siswa", 
                   style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              
              TextField(
                controller: controller.namaC,
                decoration: InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              SizedBox(height: 10),
              TextField(
                controller: controller.nisnC,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "NISN (Untuk Login)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              SizedBox(height: 10),
              
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedKelasId.value.isEmpty ? null : controller.selectedKelasId.value,
                hint: Text("Pilih Kelas"),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
                items: controller.listKelas.map<DropdownMenuItem<String>>((kelas) {
                  return DropdownMenuItem<String>(
                    value: kelas['id'].toString(),
                    child: Text(kelas['nama_kelas']),
                  );
                }).toList(),
                onChanged: (val) => controller.selectedKelasId.value = val!,
              )),

              SizedBox(height: 10),
              TextField(
                controller: controller.passC,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password " + (item == null ? "(Default: 123456)" : "(Isi jika ingin ubah)"), 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                ),
              ),
              
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity, 
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.simpanSiswa(id: item != null ? item['id'].toString() : null),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                  child: Text("SIMPAN"),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(int id) {
    Get.defaultDialog(
      title: "Hapus Siswa",
      middleText: "Yakin ingin menghapus data siswa ini?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.hapusSiswa(id);
      },
    );
  }
}