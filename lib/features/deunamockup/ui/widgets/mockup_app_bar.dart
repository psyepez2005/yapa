import 'package:flutter/material.dart';

class MockupAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MockupAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16.0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE9E7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE64A19), width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Text('EP', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 14.0)),
              ),
              const SizedBox(width: 12.0),
              const Text('Hola Emilio 👋', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0)),
            ],
          ),
          Row(
            children: const [
              Icon(Icons.notifications_none, color: Colors.black, size: 26),
              SizedBox(width: 16.0),
              Icon(Icons.headset_mic_outlined, color: Colors.black, size: 26),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}