import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isFlashOn = false;
  bool _hasScanned = false;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_hasScanned && scanData.code != null) {
        _hasScanned = true;
        controller.pauseCamera();
        _handleScannedCode(scanData.code!);
      }
    });
  }

  void _handleScannedCode(String code) {
    debugPrint('🎯 QR Code scanned: $code');
    
    // QR kodundan event kodunu çıkar
    // Örnek: https://pixlomi.com/event/PX-ABC123 veya direkt PX-ABC123
    String eventCode = code;
    
    if (code.contains('PX-')) {
      final regex = RegExp(r'PX-[A-Z0-9]{6}');
      final match = regex.firstMatch(code);
      if (match != null) {
        eventCode = match.group(0)!;
      }
    }
    
    // Sonucu geri döndür
    Navigator.pop(context, eventCode);
  }

  void _toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // Kamerayı durdur
        controller?.pauseCamera();
        
        // Kullanıcıya bilgi ver
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR kodu aranıyor...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        // QR kodu oku
        try {
          final inputImage = InputImage.fromFilePath(image.path);
          final barcodeScanner = BarcodeScanner();
          final barcodes = await barcodeScanner.processImage(inputImage);
          
          await barcodeScanner.close();
          
          if (barcodes.isNotEmpty) {
            // İlk QR kodu al
            final qrCode = barcodes.first.rawValue;
            
            if (qrCode != null && qrCode.isNotEmpty) {
              // QR kod bulundu
              _handleScannedCode(qrCode);
            } else {
              // QR kod boş
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('QR kodu okunamadı'),
                    backgroundColor: Colors.red,
                  ),
                );
                controller?.resumeCamera();
              }
            }
          } else {
            // QR kod bulunamadı
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resimde QR kodu bulunamadı'),
                  backgroundColor: Colors.red,
                ),
              );
              controller?.resumeCamera();
            }
          }
        } catch (e) {
          debugPrint('❌ QR decode error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('QR kodu okunamadı. Lütfen net bir QR kodu resmi seçin.'),
                backgroundColor: Colors.red,
              ),
            );
            controller?.resumeCamera();
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Gallery picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Galeri açılırken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
        controller?.resumeCamera();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // QR Scanner View
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: AppTheme.primary,
              borderRadius: 16,
              borderLength: 40,
              borderWidth: 8,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
          ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Geri butonu
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  // Flaş butonu
                  GestureDetector(
                    onTap: _toggleFlash,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Alt bilgi ve galeri butonu
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Galeri butonu
                    GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Galeriden QR Seç',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'QR Kodu Tarayın',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Etkinlik QR kodunu kare içine yerleştirin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
