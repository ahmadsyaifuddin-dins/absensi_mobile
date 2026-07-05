import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/admin_controller.dart';

class ManajemenGuruView extends StatelessWidget {
  final AdminController controller = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manajemen Pegawai", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.red[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[800],
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showFormDialog(context),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.listGuru.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.listGuru.isEmpty) return Center(child: Text("Belum ada data pegawai"));

        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: controller.listGuru.length,
          itemBuilder: (context, index) {
            var item = controller.listGuru[index];
            
            // Format Label Role agar lebih rapi di list
            String labelRole = "Guru";
            if (item['role'] == 'kepsek') labelRole = "Kepala Sekolah";
            if (item['role'] == 'guru_bk') labelRole = "Guru BK";

            return Card(
              margin: EdgeInsets.only(bottom: 10),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red[100],
                  child: Text(item['nama'][0], style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold)),
                ),
                title: Text(item['nama'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text("Role: $labelRole\nNIP: ${item['nisn_nip'] ?? '-'}\n${item['email']}", style: GoogleFonts.poppins(fontSize: 12)),
                isThreeLine: true,
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showFormDialog(context, item: item);
                    } else if (value == 'delete') {
                      Get.defaultDialog(
                        title: "Hapus Pegawai?",
                        middleText: "Data yang dihapus tidak bisa kembali.",
                        textConfirm: "Hapus", textCancel: "Batal",
                        confirmTextColor: Colors.white, buttonColor: Colors.red,
                        onConfirm: () => controller.deleteGuru(item['id'].toString())
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text("Edit Data")),
                    PopupMenuItem(value: 'delete', child: Text("Hapus")),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // --- DIALOG FORM TAMBAH/EDIT ---
  void _showFormDialog(BuildContext context, {Map? item}) {
    // Jika Edit, isi form dengan data lama
    if (item != null) {
      controller.namaC.text = item['nama'];
      controller.nipC.text = item['nisn_nip'] ?? '';
      controller.emailC.text = item['email'];
      controller.passC.text = ""; 
      controller.selectedRole.value = item['role'] ?? 'guru';
    } else {
      controller.clearForm();
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item == null ? "Tambah Pegawai Baru" : "Edit Data Pegawai",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              
              TextField(
                controller: controller.namaC,
                decoration: InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              
              TextField(
                controller: controller.nipC,
                decoration: InputDecoration(labelText: "NIP / NUPTK", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),

              // --- DROPDOWN ROLE ---
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedRole.value,
                decoration: InputDecoration(
                  labelText: "Hak Akses / Role", 
                  border: OutlineInputBorder(),
                  filled: item != null, // Visual cue kalau terkunci
                  fillColor: item != null ? Colors.grey[200] : Colors.white,
                  helperText: item != null ? "Role tidak dapat diubah saat mengedit data." : null,
                ),
                items: [
                  DropdownMenuItem(value: 'guru', child: Text("Guru Mata Pelajaran / Wali Kelas")),
                  DropdownMenuItem(value: 'kepsek', child: Text("Kepala Sekolah")),
                  DropdownMenuItem(value: 'guru_bk', child: Text("Guru Bimbingan Konseling (BK)")),
                ],
                // KUNCI DROPDOWN SAAT EDIT: Jika item tidak null, onChanged dibuat null
                onChanged: item != null 
                    ? null 
                    : (val) {
                        if (val != null) controller.selectedRole.value = val;
                      },
              )),
              SizedBox(height: 10),

              TextField(
                controller: controller.emailC,
                decoration: InputDecoration(labelText: "Email Login", border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              
              TextField(
                controller: controller.passC,
                decoration: InputDecoration(
                  labelText: item == null ? "Password" : "Password (Isi jika ingin ubah)",
                  border: OutlineInputBorder(),
                  helperText: item == null ? "Min. 6 karakter" : "Biarkan kosong jika tidak mengubah password"
                ),
                obscureText: true,
              ),
              
              SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  padding: EdgeInsets.symmetric(vertical: 15)
                ),
                child: Text("SIMPAN", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  controller.saveGuru(id: item != null ? item['id'].toString() : null);
                },
              ))
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}