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
        bool isCompleted = index < currentSteps;

        return Expanded(
          child: Container(
            height: 12,
            margin: EdgeInsets.only(
              right: index == totalSteps - 1 ? 0 : 8,
            ),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF00BFA5)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }
}