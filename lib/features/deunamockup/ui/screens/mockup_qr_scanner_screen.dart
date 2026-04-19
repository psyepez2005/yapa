import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MockupQrScannerScreen extends StatefulWidget {
  const MockupQrScannerScreen({super.key});

  @override
  State<MockupQrScannerScreen> createState() => _MockupQrScannerScreenState();
}

class _MockupQrScannerScreenState extends State<MockupQrScannerScreen> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _scanned = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    _processQr(raw);
  }

  void _processQr(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.scheme != 'deuna' || uri.host != 'merchant') {
      _showError('QR inválido. Escanea el código de un negocio Deuna.');
      return;
    }
    final merchantId = uri.pathSegments.firstOrNull;
    if (merchantId == null || merchantId.isEmpty) {
      _showError('QR inválido. No se encontró el ID del negocio.');
      return;
    }
    setState(() => _scanned = true);

    const mockMerchantNames = {
      'm001': 'Ceviches de la Ruleta',
      '66952548-3805-41ff-b4fd-607572313c34': 'Ceviches de la Ruleta',
      'm010': 'Jugos Naturales Pacheco',
      '1a21ad8c-b447-4784-82a5-8c540ceeb38b': 'Jugos Naturales Pacheco',
      'm020': 'Wok Chino Restaurante',
      'c1a5924d-795f-4b82-8c0c-42875e76970c': 'Wok Chino Restaurante',
      'm030': 'Tienda Escolar El Saber',
      'f899d880-0f70-4fed-bd2a-2f75de599ef1': 'Tienda Escolar El Saber',
    };
    final nameParam = uri.queryParameters['name'];
    final merchantName = (nameParam != null && nameParam.isNotEmpty) 
        ? nameParam 
        : (mockMerchantNames[merchantId] ?? 'Negocio');
    final amountStr = uri.queryParameters['amount'];

    // Si QR ya trae monto fijo → saltar pantalla de monto e ir directo a confirmación
    if (amountStr != null && amountStr.isNotEmpty) {
      final amount = double.tryParse(amountStr);
      if (amount != null && amount > 0) {
        context.pushNamed('payment_confirmation', extra: {
          'merchantId': merchantId,
          'merchantName': merchantName,
          'amount': amount.toStringAsFixed(2),
        });
        return;
      }
    }

    // Sin monto en QR → pantalla de ingreso de monto
    context.pushNamed('payment_amount', extra: {
      'merchantId': merchantId,
      'merchantName': merchantName,
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() => _scanned = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _ctrl, onDetect: _handleBarcode),
          const _ScannerOverlay(),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TopBtn(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => context.pop(),
                      ),
                      _TopBtn(
                        icon: _torchOn ? Icons.flashlight_off : Icons.flashlight_on,
                        onTap: () {
                          _ctrl.toggleTorch();
                          setState(() => _torchOn = !_torchOn);
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: const [
                      Text(
                        'Apunta al QR del negocio',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'El código se detectará automáticamente',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frameSize = size.width * 0.7;
    final left = (size.width - frameSize) / 2;
    final top = (size.height - frameSize) / 2 - 40;
    final rect = Rect.fromLTWH(left, top, frameSize, frameSize);

    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
        ..fillType = PathFillType.evenOdd,
      Paint()..color = Colors.black54,
    );

    final p = Paint()
      ..color = const Color(0xFF00BFA5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const cLen = 24.0;

    void corner(Offset a, Offset mid, Offset b) {
      canvas.drawPath(Path()..moveTo(a.dx, a.dy)..lineTo(mid.dx, mid.dy)..lineTo(b.dx, b.dy), p);
    }

    corner(Offset(left, top + cLen), Offset(left, top), Offset(left + cLen, top));
    corner(Offset(left + frameSize - cLen, top), Offset(left + frameSize, top), Offset(left + frameSize, top + cLen));
    corner(Offset(left + frameSize, top + frameSize - cLen), Offset(left + frameSize, top + frameSize), Offset(left + frameSize - cLen, top + frameSize));
    corner(Offset(left + cLen, top + frameSize), Offset(left, top + frameSize), Offset(left, top + frameSize - cLen));
  }

  @override
  bool shouldRepaint(_OverlayPainter _) => false;
}
