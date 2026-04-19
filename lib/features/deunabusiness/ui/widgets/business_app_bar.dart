import 'package:flutter/material.dart';

class BusinessAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String merchantName;
  final VoidCallback? onLogout;

  const BusinessAppBar({
    super.key,
    this.merchantName = '',
    this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = merchantName.isNotEmpty ? merchantName : 'Comerciante';
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
            '$_greeting, $displayName',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'deuna! Negocios',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black87),
          tooltip: 'Notificaciones',
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'logout' && onLogout != null) onLogout!();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'support',
              child: Row(
                children: [
                  Icon(Icons.headset_mic_outlined, color: Color(0xFF4A1587), size: 20),
                  SizedBox(width: 12),
                  Text('Soporte'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
