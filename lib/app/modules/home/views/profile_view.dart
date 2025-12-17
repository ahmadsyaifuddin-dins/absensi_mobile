import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/profile_controller.dart';
import '../../../data/providers/api_config.dart';

class ProfileView extends StatelessWidget {
  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Saya", style: GoogleFonts.poppins()),
        backgroundColor: Colors.blueAccent, // Sesuaikan warna user (Guru/Siswa)
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            
            // --- FOTO PROFIL ---
            Obx(() {
              var user = controller.user.value;
              var foto = user['foto_profil'];
              
              return Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 3),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: foto != null 
                            ? NetworkImage("${ApiConfig.imageUrl}$foto")
                            : AssetImage("assets/logo.png") as ImageProvider, // Ganti asset default kalau ada
                            // Atau pakai Icon kalau gak ada asset
                        ),
                      ),
                      child: foto == null ? Icon(Icons.person, size: 60, color: Colors.grey) : null,
                    ),
                    // Tombol Edit Foto Kecil
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () => controller.updateFoto(),
                        child: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          radius: 18,
                          child: controller.isLoading.value 
                            ? Padding(padding: EdgeInsets.all(4), child: CircularProgressIndicator(color: Colors.white)) 
                            : Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),

            SizedBox(height: 15),
            
            // --- INFO USER ---
            Obx(() => Text(
              controller.user['nama'] ?? "User",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            )),
            Obx(() => Text(
              controller.user['role'] == 'guru' ? "NIP: ${controller.user['nisn_nip']}" : "NISN: ${controller.user['nisn_nip']}",
              style: GoogleFonts.poppins(color: Colors.grey),
            )),

            SizedBox(height: 30),
            Divider(),

            // --- MENU PILIHAN ---
            ListTile(
              leading: Icon(Icons.lock_outline, color: Colors.blueAccent),
              title: Text("Ganti Password", style: GoogleFonts.poppins()),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showChangePasswordDialog(context),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text("Keluar Aplikasi", style: GoogleFonts.poppins(color: Colors.redAccent)),
              onTap: () => controller.logout(),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG GANTI PASSWORD ---
  void _showChangePasswordDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ganti Password", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              
              TextField(
                controller: controller.oldPassC,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password Lama", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: controller.newPassC,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password Baru", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: controller.confirmPassC,
                obscureText: true,
                decoration: InputDecoration(labelText: "Ulangi Password Baru", border: OutlineInputBorder()),
              ),
              
              SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.changePassword(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  child: controller.isLoading.value 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("SIMPAN PASSWORD BARU"),
                )),
              )
            ],
          ),
        ),
      )
    );
  }
}