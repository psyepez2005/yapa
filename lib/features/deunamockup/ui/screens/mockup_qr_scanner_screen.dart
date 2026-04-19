import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';class MockupQrScannerScreen extends StatelessWidget {
  const MockupQrScannerScreen({super.key});

  // Este es el método que crea la ventana emergente
  void _showSimulatedScanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2F1), // Fondo turquesa clarito
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.qr_code_scanner, color: Color(0xFF00BFA5), size: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Código detectado!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tienda Don Pepe',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4A1587),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '¿Deseas proceder con el pago?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el modal
                      context.pushNamed('payment_amount'); // Nueva redirección
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A1587),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // Cierra el modal
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- CAPA DE FONDO (LA "CÁMARA") ---
          Image.network(
            'https://images.unsplash.com/photo-1542831371-29b0f74f9713?q=80&w=1000&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),
          
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // --- CAPA DE INTERFAZ ---
          SafeArea(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Escanea el código QR para pagar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // ✅ AQUÍ ESTÁ EL ÁREA INTERACTIVA
                    Center(
                      child: Material(
                        color: Colors.transparent, // Transparente para ver el fondo
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          splashColor: const Color(0xFF00BFA5).withOpacity(0.3), // Splash turquesa
                          highlightColor: const Color(0xFF00BFA5).withOpacity(0.1),
                          onTap: () => _showSimulatedScanDialog(context), // Llama al modal
                          child: SizedBox(
                            width: 250,
                            height: 250,
                            child: CustomPaint(
                              painter: _QrCornerPainter(color: const Color(0xFF00BFA5)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 80), 
                  ],
                ),

                // --- BARRA SUPERIOR ---
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TopControlButton(
                        icon: Icons.arrow_back_ios_new,
                        iconColor: Colors.black,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      _TopControlButton(
                        icon: Icons.flashlight_on,
                        iconColor: const Color(0xFF4A1587),
                        onTap: () {
                          debugPrint('Linterna encendida/apagada');
                        },
                      ),
                    ],
                  ),
                ),

                // --- BOTONES INFERIORES ---
                Positioned(
                  bottom: 40,
                  left: 24,
                  right: 24,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _showSimulatedScanDialog(context),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                            return const Color(0xFF4A1587); // Morado hover
                          }
                          return Colors.white; // Blanco por defecto
                        }),
                        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                            return Colors.white;
                          }
                          return const Color(0xFF4A1587);
                        }),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        elevation: MaterialStateProperty.all(2),
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                      child: const Text('Continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
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

// --- WIDGETS PRIVADOS ---

class _TopControlButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _TopControlButton({required this.icon, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}



class _QrCornerPainter extends CustomPainter {
  final Color color;
  _QrCornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 40.0;
    const double radius = 16.0;

    // Arriba Izquierda
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, radius)
        ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
        ..lineTo(cornerLength, 0),
      paint,
    );

    // Arriba Derecha
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width - radius, 0)
        ..arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius))
        ..lineTo(size.width, cornerLength),
      paint,
    );

    // Abajo Derecha
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - cornerLength)
        ..lineTo(size.width, size.height - radius)
        ..arcToPoint(Offset(size.width - radius, size.height), radius: const Radius.circular(radius))
        ..lineTo(size.width - cornerLength, size.height),
      paint,
    );

    // Abajo Izquierda
    canvas.drawPath(
      Path()
        ..moveTo(cornerLength, size.height)
        ..lineTo(radius, size.height)
        ..arcToPoint(Offset(0, size.height - radius), radius: const Radius.circular(radius))
        ..lineTo(0, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}