import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Section
              Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo deuna!
                  const Text(
                    'deuna!',
                    style: TextStyle(
                      color: Color(0xFF4A1587), // Morado DeUna
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // QR Area
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Custom borders like a scanner
                      CustomPaint(
                        size: const Size(260, 260),
                        painter: _QRCornersPainter(),
                      ),
                      // El QR falso
                      const Icon(Icons.qr_code_2, size: 220, color: Colors.black87),
                      // El d! central
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'd!',
                          style: TextStyle(
                            color: Color(0xFF4A1587),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Usa este QR o Nro de cuenta para cobrar',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Nro. ******5424',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.copy, size: 16, color: Colors.grey.shade600),
                    ],
                  ),
                ],
              ),

              // Bottom Section
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSquareButton(
                        iconWidget: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.train, color: Colors.white, size: 20),
                        ),
                        label: 'Metro UIO',
                      ),
                      const SizedBox(width: 20),
                      _buildSquareButton(
                        iconWidget: const Icon(Icons.qr_code_scanner, color: Colors.black87, size: 28),
                        label: 'Escanear QR',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegar al Dashboard general
                        context.go('/mockup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A1587),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ingresar a Deuna',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegar al Dashboard de Lealtad (Business POS)
                        context.go('/business');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A9E8F), // Verde azulado / turquesa de la imagen
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ingresar a DeunaBusiness',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareButton({required Widget iconWidget, required String label}) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor personalizado para dibujar las esquinas del recuadro del QR
class _QRCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A1587)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    const double length = 20.0;

    // Arriba Izquierda
    canvas.drawLine(const Offset(0, 0), const Offset(length, 0), paint); // Horizontal
    canvas.drawLine(const Offset(0, 0), const Offset(0, length), paint); // Vertical

    // Arriba Derecha
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - length, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);

    // Abajo Izquierda
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - length), paint);

    // Abajo Derecha
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - length, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
