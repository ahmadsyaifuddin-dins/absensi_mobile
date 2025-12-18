import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/hari_libur_controller.dart';

class HariLiburView extends StatelessWidget {
  final controller = Get.put(HariLiburController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Atur Hari Libur", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.red[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[800],
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showFormDialog(context),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return Center(child: CircularProgressIndicator());
        
        if (controller.listLibur.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available, size: 80, color: Colors.grey[300]),
                SizedBox(height: 10),
                Text("Tidak ada jadwal libur", style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: controller.listLibur.length,
          itemBuilder: (context, index) {
            var item = controller.listLibur[index];
            // Parsing tanggal biar cantik (Senin, 17 Agustus 2025)
            DateTime date = DateTime.parse(item['tanggal']);
            String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

            return Card(
              margin: EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.calendar_month, color: Colors.red[800]),
                ),
                title: Text(item['keterangan'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text(formattedDate, style: GoogleFonts.poppins(color: Colors.grey[600])),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Hapus?",
                      middleText: "Hapus libur ${item['keterangan']}?",
                      textConfirm: "Ya", textCancel: "Batal",
                      confirmTextColor: Colors.white, buttonColor: Colors.red,
                      onConfirm: () => controller.deleteLibur(item['id']),
                    );
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Dialog Form Tambah
  void _showFormDialog(BuildContext context) {
    controller.selectedDate.value = DateTime.now(); // Reset tanggal ke hari ini
    
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tambah Hari Libur", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            
            // Picker Tanggal
            Text("Pilih Tanggal", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 5),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(), // Gak boleh set libur masa lalu
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  controller.selectedDate.value = picked;
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(controller.selectedDate.value),
                      style: GoogleFonts.poppins(),
                    )),
                    Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: controller.keteranganC,
              decoration: InputDecoration(
                labelText: "Keterangan (Misal: Cuti Bersama)",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text("SIMPAN", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => controller.addLibur(),
            )),
            SizedBox(height: 10), // Padding bawah
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}