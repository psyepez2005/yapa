import 'package:flutter/material.dart';

class TrustPointsProgress extends StatelessWidget {
  final int currentPoints;
  final int targetPoints;

  const TrustPointsProgress({
    super.key,
    required this.currentPoints,
    required this.targetPoints,
  });

  @override
  Widget build(BuildContext context) {
    // Cálculo seguro del progreso (evitar división por cero)
    final double progress = targetPoints > 0 ? (currentPoints / targetPoints) : 0.0;
    // Aseguramos que la barra no sobrepase el 100% visualmente
    final double safeProgress = progress > 1.0 ? 1.0 : progress;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -5), // Sombra hacia arriba para destacar en el fondo
          )
        ],
      ),
      child: SafeArea(
        top: false, // Solo respeta el safe area inferior (para los gestos de iOS/Android)
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Meta para recompensa',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                Icon(Icons.card_giftcard, color: Color(0xFF00BFA5), size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Texto de puntos (Ej: 50 / 500)
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'), // Fuente por defecto
                    children: [
                      TextSpan(
                        text: '$currentPoints ',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A1587), fontSize: 18),
                      ),
                      TextSpan(
                        text: '/ $targetPoints pts',
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Barra de progreso alineada a la derecha
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: safeProgress,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF00BFA5), // Turquesa DeUna
                      minHeight: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}