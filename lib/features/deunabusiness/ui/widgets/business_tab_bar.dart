import 'package:flutter/material.dart';

class BusinessTabBar extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabChanged;

  const BusinessTabBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onTabChanged(0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: currentTab == 0 ? const Color(0xFF4A1587) : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Cobrar',
                    style: TextStyle(
                      color: currentTab == 0 ? const Color(0xFF4A1587) : Colors.blueGrey,
                      fontWeight: currentTab == 0 ? FontWeight.bold : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onTabChanged(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: currentTab == 1 ? const Color(0xFF4A1587) : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Gestionar',
                    style: TextStyle(
                      color: currentTab == 1 ? const Color(0xFF4A1587) : Colors.blueGrey,
                      fontWeight: currentTab == 1 ? FontWeight.bold : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(height: 1.5, color: Colors.grey.shade200),
      ],
    );
  }
}
