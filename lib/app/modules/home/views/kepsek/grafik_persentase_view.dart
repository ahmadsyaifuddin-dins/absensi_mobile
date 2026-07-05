import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart'; 
import '../../controllers/laporan_controller.dart';

class GrafikPersentaseView extends StatelessWidget {
  final LaporanController controller = Get.put(LaporanController());

  @override
  Widget build(BuildContext context) {
    // Pastikan memanggil data grafik saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDataGrafik();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Analitik Kehadiran Hari Ini", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal[800], // Samakan dengan tema Kepsek
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: Colors.teal[800]));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        "Statistik Sekolah Real-time",
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal[900]),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Data diambil berdasarkan presensi siswa hari ini.",
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 30),
                      
                      // WIDGET PIE CHART
                      SizedBox(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 50, 
                            sections: [
                              PieChartSectionData(
                                color: Colors.green,
                                value: controller.pctHadir.value,
                                title: '${controller.pctHadir.value.toInt()}%',
                                radius: 60,
                                titleStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: Colors.orange,
                                value: controller.pctSakit.value,
                                title: '${controller.pctSakit.value.toInt()}%',
                                radius: 55,
                                titleStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: Colors.blue,
                                value: controller.pctIzin.value,
                                title: '${controller.pctIzin.value.toInt()}%',
                                radius: 55,
                                titleStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: Colors.redAccent,
                                value: controller.pctAlpa.value,
                                title: '${controller.pctAlpa.value.toInt()}%',
                                radius: 55,
                                titleStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 30),

                      // --- LEGEND (KETERANGAN WARNA) ---
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 15,
                        runSpacing: 10,
                        children: [
                          _buildLegendItem(Colors.green, "Hadir (${controller.pctHadir.value.toInt()}%)"),
                          _buildLegendItem(Colors.orange, "Sakit (${controller.pctSakit.value.toInt()}%)"),
                          _buildLegendItem(Colors.blue, "Izin (${controller.pctIzin.value.toInt()}%)"),
                          _buildLegendItem(Colors.redAccent, "Alpa (${controller.pctAlpa.value.toInt()}%)"),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // INFO BOX KHUSUS KEPSEK
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.withOpacity(0.3))
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.teal[800]),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Insight Eksekutif",
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.teal[800]),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Grafik ini menunjukkan proporsi kehadiran seluruh siswa pada hari ini. Jika persentase 'Alpa' melebihi 15%, sistem merekomendasikan Bapak/Ibu untuk berkoordinasi dengan Guru BK.",
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.teal[900]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: 6),
        Text(text, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w500)),
      ],
    );
  }
}