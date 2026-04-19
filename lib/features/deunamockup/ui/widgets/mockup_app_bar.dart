import 'package:flutter/material.dart';
import '../../../../core/storage/token_storage.dart';

class MockupAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MockupAppBar({super.key});

  @override
  State<MockupAppBar> createState() => _MockupAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MockupAppBarState extends State<MockupAppBar> {
  String _firstName = 'Usuario';
  String _initials = 'US';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final fullName = await TokenStorage.getUserName() ?? 'Usuario Deuna';
    if (!mounted) return;

    final parts = fullName.split(' ');
    String first = parts.isNotEmpty ? parts[0] : 'Usuario';
    String initials = '';

    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (first.length >= 2) {
      initials = first.substring(0, 2).toUpperCase();
    } else {
      initials = 'US';
    }

    setState(() {
      _firstName = first;
      _initials = initials;
    });
  }

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
                child: Text(_initials, style: const TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 14.0)),
              ),
              const SizedBox(width: 12.0),
              Text('Hola $_firstName 👋', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0)),
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
}