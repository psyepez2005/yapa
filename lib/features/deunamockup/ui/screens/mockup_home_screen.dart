import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart'; // Asegúrate de que la ruta coincida con tu estructura

class MockupHomeScreen extends StatelessWidget {
  const MockupHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // Color de fondo claro del SVG
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16.0,
        title: const _AppBarContent(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0), // Padding extra abajo para el botón flotante
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _BalanceCard(),
            SizedBox(height: 16.0),
            _PromoBanner(),
            SizedBox(height: 24.0),
            _ServiceGrid(),
            SizedBox(height: 32.0),
            _PromotionsSection(), // Nueva sección añadida
          ],
        ),
      ),
      // Botón flotante de Escanear QR
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        width: double.infinity,
        height: 56,
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: const Color(0xFF4A1587), // Morado DeUna
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          label: const Text(
            'Escanear QR',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _AppBarContent extends StatelessWidget {
  const _AppBarContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFBE9E7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE64A19), width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Text(
                'EP',
                style: TextStyle(
                  color: Color(0xFF4A1587),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            const Text(
              'Hola Emilio',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            const SizedBox(width: 8.0),
            Container(width: 20, height: 20, color: const Color(0xFF1A237E)), // Cuadro placeholder del saludo
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
              child: const Icon(Icons.notifications, color: Color(0xFF1A237E), size: 20),
            ),
            const SizedBox(width: 12.0),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
              child: const Icon(Icons.headset_mic, color: Color(0xFF1A237E), size: 20),
            ),
          ],
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo disponible',
                      style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14.0),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: const [
                        Text(
                          '\$0,00',
                          style: TextStyle(color: Color(0xFF0F172A), fontSize: 36.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 12.0),
                        Icon(Icons.visibility_off, color: Color(0xFF9E9E9E), size: 20),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF4A1587), size: 32),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Recargar desde', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12.0)),
                    SizedBox(height: 4.0),
                    Text('Principal ******2634', style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '+ \$20',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'deuna!',
                        style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 14.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6FA), // Morado claro
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '\$50 dsct. en compras desde \$200\n+ envío gratis pagando con Deu...',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: const [
                    Text(
                      'Comprar con Deuna',
                      style: TextStyle(
                        color: Color(0xFF4A1587),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.0),
                    Icon(Icons.arrow_outward, color: Color(0xFF4A1587), size: 16),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            color: const Color(0xFF4A1587), // Placeholder imagen banner
          ),
        ],
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid();

  @override
  Widget build(BuildContext context) {
    // 10 elementos según el SVG
    final services = [
      'Transferir', 'Transferir a\notro banco', 'Recargar', 'Cobrar',
      'Retirar', 'Recarga\ncelular', 'Pagar\nservicios', 'Metro de\nQuito',
      'Deuna\nJóvenes', 'Tienda\nDeuna'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              alignment: Alignment.center,
              child: Container(
                width: 24, height: 24, 
                color: const Color(0xFF1A237E), // Placeholder del ícono oscuro
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              services[index],
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 11.0, height: 1.2),
            ),
          ],
        );
      },
    );
  }
}

class _PromotionsSection extends StatelessWidget {
  const _PromotionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mis promociones',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220, // Altura ajustada para las tarjetas
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: const [
              _PromoCard(
                topColor: Color(0xFF4A1587),
                topContent: Text('3\npagos y\ngana', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.1)),
                tagText: 'Sorteo',
                title: 'Gana en\ngrande',
                subtitle: 'Haz 3 pagos en co...',
              ),
              SizedBox(width: 16),
              _PromoCard(
                topColor: Color(0xFF00BCD4), // Turquesa
                topContent: Center(child: Text('GIVEAWAY', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                tagText: 'Sorteo',
                title: 'Infinix',
                subtitle: '¡El próximo Infinix\nNote 60 Pro...',
              ),
              SizedBox(width: 16),
              _PromoCard(
                topColor: Color(0xFFF0E68C), // Amarillo
                topContent: Center(child: Text('Go...', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
                tagText: 'Regre...',
                title: '\$10 d...\nReem...',
                subtitle: 'Por com...',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  final Color topColor;
  final Widget topContent;
  final String tagText;
  final String title;
  final String subtitle;

  const _PromoCard({
    required this.topColor,
    required this.topContent,
    required this.tagText,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: topColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: topContent,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA5), // Verde Sorteo
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(tagText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.2)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4A1587),
        unselectedItemColor: const Color(0xFFBDBDBD),
        currentIndex: 3, // El SVG tiene seleccionada la pestaña "Tú"
        elevation: 0,
        items: [
          _buildNavItem(Icons.circle, 'Inicio', false),
          _buildNavItem(Icons.circle, 'Beneficios', false),
          _buildNavItem(Icons.circle, 'Billetera', false),
          _buildNavItem(Icons.circle, 'Tú', true),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, bool isSelected) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Icon(icon, size: 8, color: isSelected ? const Color(0xFF4A1587) : const Color(0xFFE0E0E0)),
      ),
      label: label,
    );
  }
}