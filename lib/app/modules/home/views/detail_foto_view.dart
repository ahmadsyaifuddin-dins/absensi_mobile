import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailFotoView extends StatelessWidget {
  final String imageUrl;

  const DetailFotoView({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam biar fokus
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text("Bukti Izin", style: GoogleFonts.poppins()),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        // InteractiveViewer bikin gambar bisa dicubit (Zoom In/Out)
        child: InteractiveViewer(
          panEnabled: true, // Bisa digeser
          boundaryMargin: EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0, // Bisa zoom sampai 4x lipat
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return CircularProgressIndicator(color: Colors.white);
            },
            errorBuilder: (ctx, err, stack) => 
              Text("Gagal memuat gambar", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}