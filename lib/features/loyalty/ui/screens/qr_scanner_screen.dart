import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:yapa/features/loyalty/ui/widgets/scan_amount_sheet.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _ctrl = MobileScannerController();
  final TextEditingController _manualCtrl = TextEditingController();
  bool _scanned = false;
  bool _showManual = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _manualCtrl.dispose();
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
    final amountStr = uri.queryParameters['amount'];
    setState(() => _scanned = true);
    _openAmountSheet(merchantId, amountStr);
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  void _openAmountSheet(String merchantId, [String? prefillAmount]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanAmountSheet(
        merchantId: merchantId,
        prefillAmount: prefillAmount,
        onDone: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    ).then((_) {
      if (mounted) setState(() => _scanned = false);
    });
  }

  void _submitManual() {
    final id = _manualCtrl.text.trim();
    if (id.isEmpty) return;
    _openAmountSheet(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Escanear Negocio'),
        actions: [
          IconButton(
            icon: Icon(_showManual ? Icons.qr_code_scanner : Icons.keyboard),
            onPressed: () => setState(() => _showManual = !_showManual),
            tooltip: _showManual ? 'Usar cámara' : 'Ingresar manualmente',
          ),
        ],
      ),
      body: _showManual ? _buildManualEntry() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(controller: _ctrl, onDetect: _handleBarcode),
        const _ScannerOverlay(),
        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const Text(
                'Apunta al QR del negocio',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _showManual = true),
                child: const Text(
                  'Ingresar ID manualmente',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntry() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store_outlined, color: Colors.white54, size: 64),
          const SizedBox(height: 24),
          const Text(
            'Ingresa el ID del negocio',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Solicítalo al dueño del negocio',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _manualCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'merchant-uuid...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitManual,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A1587),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
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

    final overlayPaint = Paint()..color = Colors.black54;
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const cLen = 24.0;

    void drawCorner(Offset start, Offset mid, Offset end) {
      canvas.drawPath(
        Path()..moveTo(start.dx, start.dy)..lineTo(mid.dx, mid.dy)..lineTo(end.dx, end.dy),
        cornerPaint,
      );
    }

    drawCorner(Offset(left, top + cLen), Offset(left, top), Offset(left + cLen, top));
    drawCorner(Offset(left + frameSize - cLen, top), Offset(left + frameSize, top), Offset(left + frameSize, top + cLen));
    drawCorner(Offset(left + frameSize, top + frameSize - cLen), Offset(left + frameSize, top + frameSize), Offset(left + frameSize - cLen, top + frameSize));
    drawCorner(Offset(left + cLen, top + frameSize), Offset(left, top + frameSize), Offset(left, top + frameSize - cLen));
  }

  @override
  bool shouldRepaint(_OverlayPainter _) => false;
}
