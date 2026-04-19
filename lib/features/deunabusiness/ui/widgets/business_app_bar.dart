import 'package:flutter/material.dart';

class BusinessAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String greeting;
  final String subtitle;

  const BusinessAppBar({
    super.key,
    this.greeting = 'Hola, Comerciante',
    this.subtitle = 'deuna! Negocios',
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 8,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: CircleAvatar(
          backgroundColor: const Color(0xFFE8EAF6),
          child: const Icon(Icons.storefront, color: Color(0xFF4A1587), size: 18),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black87),
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40),
        ),
        IconButton(
          icon: const Icon(Icons.headset_mic_outlined, color: Colors.black87),
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
