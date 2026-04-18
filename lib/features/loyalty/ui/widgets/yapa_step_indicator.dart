import 'package:flutter/material.dart';

class YapaStepIndicator extends StatelessWidget {
  final int currentSteps;
  final int totalSteps;

  const YapaStepIndicator({
    super.key,
    required this.currentSteps,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(totalSteps, (index) {
        // Si el índice es menor que las yapas actuales, está "completado"
        bool isCompleted = index < currentSteps;
        
        return Expanded(
          child: Container(
            height: 12, // Altura del círculo/cápsula
            margin: EdgeInsets.only(
              right: index == totalSteps - 1 ? 0 : 8, // Espacio entre círculos
            ),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? const Color(0xFF00BFA5) // Turquesa si está ganada
                  : Colors.grey.shade200,    // Gris si falta
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }
}