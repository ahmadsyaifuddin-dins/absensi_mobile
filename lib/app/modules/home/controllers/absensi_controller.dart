import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

// Import Service & Model
import '../../../data/providers/api_config.dart';
import '../../../data/models/absensi_model.dart';
import '../../../services/security_service.dart';
import '../../../services/location_service.dart';

class AbsensiController extends GetxController with WidgetsBindingObserver {
  var isLoading = false.obs;
  var isLoadingHistory = false.obs;

  // --- DATA LOKASI & SEKOLAH ---
  var currentPosition = Rxn<Position>();
  var alamat = "-".obs;
  
  // Default Koordinat (Nanti ditimpa fetchSettingSekolah)
  var schoolLat = (-3.18441686).obs;
  var schoolLng = (114.53308639).obs;
  var radiusMeter = (50.0).obs;

  // --- DATA FOTO ---
  var image = Rxn<File>(); 
  final ImagePicker picker = ImagePicker();

  // --- STATE KAMERA & FACE DETECTION ---
  var isCameraReady = false.obs;
  var isFaceDetected = false.obs;
  var cameraError = ''.obs;

  CameraController? cameraController;
  final FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableLandmarks: false,
      enableContours: false,
      enableClassification: false,
      enableTracking: false,
      minFaceSize: 0.1,
    ),
  );

  // Throttling deteksi wajah: proses maksimal tiap 500ms agar HP tidak cepat panas
  static const int _faceScanIntervalMs = 500;
  DateTime _lastFaceScan = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isProcessingFrame = false;
  bool _isCapturing = false;

  // Rotasi per orientasi device (untuk hitung rotasi InputImage)
  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  // --- DATA IZIN ---
  var kategoriIzin = 'Sakit'.obs;
  TextEditingController alasanC = TextEditingController();

  // --- DATA RIWAYAT ---
  var historyList = <Absensi>[].obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    updateLocation();         // Cari Lokasi Awal (Refactored)
    fetchSettingSekolah();    // Ambil Radius/Lokasi DB
    fetchHistory();           // Ambil Riwayat
  }

  // ==========================================
  // 1. UPDATE LOKASI (Panggil LocationService)
  // ==========================================
  Future<void> updateLocation() async {
    try {
      // Panggil Service Location
      Position pos = await LocationService.getCurrentPosition();
      currentPosition.value = pos;
      
      // Ambil Alamat
      alamat.value = await LocationService.getAddressFromCoordinates(pos.latitude, pos.longitude);
      
    } catch (e) {
      // Error handling UI disini
      print("Error Lokasi: $e"); // Boleh diprint atau snackbar kalau perlu
    }
  }

  // ==========================================
  // 2. KAMERA DEPAN + FACE DETECTION
  // ==========================================
  
  // Inisialisasi kamera depan (wajib). Dipanggil dari AbsensiView.
  Future<void> initCamera() async {
    if (isCameraReady.value || cameraController != null) return;

    // Pastikan permission kamera ditangani sebelum membuka kamera
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      cameraError.value = "Izin kamera ditolak. Aktifkan akses kamera di pengaturan.";
      return;
    }

    try {
      final cameras = await availableCameras();

      // KUNCI LENSA: hanya muat kamera depan, tanpa tombol switch
      CameraDescription? frontCamera;
      for (final c in cameras) {
        if (c.lensDirection == CameraLensDirection.front) {
          frontCamera = c;
          break;
        }
      }

      if (frontCamera == null) {
        cameraError.value = "Kamera depan tidak ditemukan di perangkat ini.";
        return;
      }

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        // Android: NV21 langsung didukung ML Kit. iOS: BGRA8888.
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await cameraController!.initialize();
      isCameraReady.value = true;
      await cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      cameraError.value = "Gagal menginisialisasi kamera: $e";
      isCameraReady.value = false;
    }
  }

  // Stream kamera -> ML Kit (dengan throttling 500ms)
  void _processCameraImage(CameraImage image) {
    if (_isProcessingFrame || _isCapturing || isClosed) return;

    final now = DateTime.now();
    if (now.difference(_lastFaceScan).inMilliseconds < _faceScanIntervalMs) return;
    _lastFaceScan = now;
    _isProcessingFrame = true;

    final InputImage? inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isProcessingFrame = false;
      return;
    }

    faceDetector.processImage(inputImage).then((faces) {
      if (!isClosed) {
        isFaceDetected.value = faces.isNotEmpty;
      }
    }).catchError((_) {
      // Abaikan frame error agar stream tidak berhenti
    }).whenComplete(() {
      _isProcessingFrame = false;
    });
  }

  // Konversi CameraImage -> InputImage yang bisa dibaca ML Kit
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final CameraController? controller = cameraController;
    if (controller == null || !controller.value.isInitialized) return null;

    final camera = controller.description;
    final sensorOrientation = camera.sensorOrientation;

    // Hitung rotasi image (dipakai Android untuk konversi native)
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    if (image.planes.isEmpty) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // hanya dipakai di Android
        format: format,     // hanya dipakai di iOS
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // Hidupkan kembali stream setelah gagal absen (agar bisa retry)
  Future<void> _resumeCameraStream() async {
    try {
      final cc = cameraController;
      if (cc == null || !cc.value.isInitialized || cc.value.isStreamingImages) return;
      await cc.startImageStream(_processCameraImage);
    } catch (_) {
      // abaikan, preview akan tetap tampil
    }
  }

  // Matikan kamera (dipanggil saat page ditutup)
  Future<void> _disposeCamera() async {
    try {
      final cc = cameraController;
      if (cc != null) {
        if (cc.value.isStreamingImages) {
          await cc.stopImageStream();
        }
        await cc.dispose();
      }
    } catch (_) {
      // abaikan
    }
    cameraController = null;
    isCameraReady.value = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cc = cameraController;
    if (cc == null || !cc.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      if (cc.value.isStreamingImages) {
        cc.stopImageStream();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (isCameraReady.value && !_isCapturing) {
        _resumeCameraStream();
      }
    }
  }

  // ==========================================
  // 3. ABSEN MASUK (CLEAN VERSION + FACE DETECTION)
  // ==========================================
  Future<void> absenMasuk(String token) async {
    // A. Validasi Face Detection
    if (!isFaceDetected.value) {
      Get.snackbar("Error", "Arahkan kamera ke wajah Anda terlebih dahulu!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    _isCapturing = true;
    bool streamStopped = false;

    try {
      // --- [LAYER 1] SECURITY CHECK (Strict) ---
      // Panggil SecurityService. Jika ada violation, dia akan throw Error.
      await SecurityService.checkDeviceIntegrity();

      // --- [LAYER 2] REFRESH LOKASI ---
      // Paksa ambil lokasi terbaru saat tombol ditekan
      await updateLocation();
      
      if (currentPosition.value == null) {
        throw "Gagal mendapatkan lokasi terkini. Coba lagi.";
      }

      // --- [LAYER 3] CEK MOCK LOCATION (Fake GPS) ---
      // Tidak ada bypass developer lagi. Semua kena.
      if (currentPosition.value!.isMocked) {
        Get.snackbar(
          "PERINGATAN KERAS! 🚨", 
          "Terdeteksi FAKE GPS! Sistem menolak lokasi palsu.",
          backgroundColor: Colors.red[900],
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          icon: Icon(Icons.warning, color: Colors.yellow, size: 30),
        );
        return;
      }

      // --- [LAYER 4] CEK RADIUS JARAK ---
      double jarak = LocationService.getDistance(
        currentPosition.value!.latitude,
        currentPosition.value!.longitude,
        schoolLat.value,
        schoolLng.value
      );

      if (jarak > radiusMeter.value) {
         throw "Jarak Terlalu Jauh! Kamu berjarak ${jarak.toInt()}m. (Maks: ${radiusMeter.value.toInt()}m)";
      }

      // --- [LAYER 5] HENTIKAN STREAM & AMBIL FOTO SELFIE ---
      streamStopped = true;
      await cameraController?.stopImageStream();
      final XFile? photo = await cameraController?.takePicture();
      if (photo == null) {
        throw 'Gagal mengambil foto selfie. Coba lagi.';
      }
      image.value = File(photo.path);

      // --- [LAYER 6] KIRIM KE SERVER ---
      await _postAbsenMasuk(token);

    } catch (e) {
      // Tangkap Error dari Service (String error message)
      if (streamStopped) {
        await _resumeCameraStream(); // hidupkan stream lagi agar bisa retry
      }
      Get.snackbar("Gagal Absen", e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      _isCapturing = false;
    }
  }

  // ==========================================
  // 4. LOGIC POST API (Private Method biar rapi)
  // ==========================================
  Future<void> _postAbsenMasuk(String token) async {
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/absensi'));
    request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    
    request.fields['latitude'] = currentPosition.value!.latitude.toString();
    request.fields['longitude'] = currentPosition.value!.longitude.toString();
    request.files.add(await http.MultipartFile.fromPath('foto', image.value!.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201 || response.statusCode == 200) {
      Get.back(); // Tutup Dialog/Halaman
      Get.snackbar("Sukses", "Absen Masuk Berhasil!", backgroundColor: Colors.green, colorText: Colors.white);
      fetchHistory(); // Refresh Riwayat
    } else {
      var msg = jsonDecode(responseBody)['message'] ?? "Gagal absen";
      throw msg; // Lempar ke catch di atas
    }
  }

  // ==========================================
  // 5. API & LAINNYA (Tetap Sama)
  // ==========================================
  
  Future<void> pickImage() async {
    // Tetap pakai image_picker untuk halaman izin (foto bukti surat)
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 50,
      preferredCameraDevice: CameraDevice.front, // Opsional: Paksa kamera depan
    );
    
    if (photo != null) {
      image.value = File(photo.path);
    }
  }

  Future<void> fetchSettingSekolah() async {
    try {
      var response = await http.get(Uri.parse('${ApiConfig.baseUrl}/sekolah'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        if (data != null) {
          schoolLat.value = double.parse(data['latitude'].toString());
          schoolLng.value = double.parse(data['longitude'].toString());
          radiusMeter.value = double.parse(data['radius_meter'].toString());
        }
      }
    } catch (e) {
      print("Err Sekolah: $e");
    }
  }

  Future<void> submitIzin(String token) async {
    if (image.value == null || alasanC.text.isEmpty) {
      Get.snackbar("Error", "Foto bukti & alasan wajib!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    isLoading.value = true;
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/absensi/izin'));
      request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});
      request.fields['status'] = kategoriIzin.value;
      request.fields['catatan'] = alasanC.text;
      request.files.add(await http.MultipartFile.fromPath('bukti_izin', image.value!.path));

      var response = await request.send();
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back();
        Get.snackbar("Sukses", "Izin berhasil diajukan", backgroundColor: Colors.green, colorText: Colors.white);
        fetchHistory();
      } else {
        Get.snackbar("Gagal", "Gagal mengajukan izin", backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHistory() async {
    try {
      isLoadingHistory.value = true;
      final box = GetStorage();
      String? token = box.read('token');
      if (token == null) return;

      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/riwayat-absensi'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'] as List;
        historyList.value = data.map((e) => Absensi.fromJson(e)).toList();
      }
    } catch (e) {
      print("Err history: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // ==========================================
  // 6. PEMBERSIHAN (Cegah Memory Leak)
  // ==========================================
  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    faceDetector.close();
    super.onClose();
  }
}
