import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MockupServiceGrid extends StatelessWidget {
  const MockupServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      // Los 8 servicios originales (ESTÁTICOS)
      {'icon': Icons.payments_outlined, 'color': const Color(0xFF00BFA5), 'label': 'Transferir'},
      {'icon': Icons.account_balance, 'color': const Color(0xFF4A1587), 'label': 'Transferir a\notro banco'},
      {'icon': Icons.phone_android, 'color': const Color(0xFF4A1587), 'label': 'Recargar'},
      {'icon': Icons.point_of_sale, 'color': const Color(0xFF00BFA5), 'label': 'Cobrar'},
      {'icon': Icons.storefront, 'color': const Color(0xFF4A1587), 'label': 'Retirar'},
      {'icon': Icons.mobile_screen_share, 'color': const Color(0xFFBA68C8), 'label': 'Recarga\ncelular'},
      {'icon': Icons.receipt_long, 'color': const Color(0xFF00BFA5), 'label': 'Pagar\nservicios'},
      {'icon': Icons.train, 'color': const Color(0xFF4A1587), 'label': 'Metro de\nQuito'},
      
      // EL 9no BOTÓN: Tu módulo de fidelización (INTERACTIVO)
      {
        'icon': Icons.stars_rounded, 
        'color': const Color(0xFFE5007D), // Rosa vibrante para que resalte
        'label': 'Mis Puntos', 
        'route': 'loyalty_dashboard' // Esta propiedad activa la navegación
      },
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
        final service = services[index];
        final bool isInteractive = service.containsKey('route');

        // Contenedor del ícono (con o sin InkWell)
        final iconWidget = Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), 
                blurRadius: 4, 
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: isInteractive
              ? Material(
                  color: Colors.transparent, // Transparente para respetar el color blanco del Container
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.pushNamed(service['route'] as String),
                    child: Center(
                      child: Icon(service['icon'] as IconData, color: service['color'] as Color, size: 28),
                    ),
                  ),
                )
              : Center( // Versión estática sin Material ni InkWell
                  child: Icon(service['icon'] as IconData, color: service['color'] as Color, size: 28),
                ),
        );

        // La columna completa (Ícono + Texto)
        final itemContent = Column(
          children: [
            iconWidget,
            const SizedBox(height: 8.0),
            Text(
              service['label'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 11.0, height: 1.2),
            ),
          ],
        );

        // Si es interactivo, envolvemos todo en un GestureDetector para capturar el toque en el texto y márgenes
        if (isInteractive) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pushNamed(service['route'] as String),
            child: itemContent,
          );
        }

        // Si no es interactivo, devolvemos solo la columna estática
        return itemContent;
      },
    );
  }
}