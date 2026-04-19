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
    final double progress = targetPoints > 0 ? (currentPoints / targetPoints) : 0.0;
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
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Progreso para tu próxima Yapa',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                Icon(Icons.card_giftcard, color: Color(0xFF00BFA5), size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
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
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: safeProgress,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF4A1587),
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