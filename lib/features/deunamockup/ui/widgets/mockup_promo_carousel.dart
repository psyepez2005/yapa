import 'package:flutter/material.dart';

class MockupPromoCarousel extends StatelessWidget {
  const MockupPromoCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Otros',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120, // Altura fija para el carrusel
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none, // Para que la sombra no se corte
            itemCount: 3, // Número de tarjetas de muestra
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _PromoListCard(index: index),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Sub-widget privado para mantener el archivo limpio
class _PromoListCard extends StatelessWidget {
  final int index;
  const _PromoListCard({required this.index});

  @override
  Widget build(BuildContext context) {
    // Colores alternados para las tarjetas de muestra
    final placeholderColors = [
      const Color.fromARGB(255, 32, 167, 86), // Morado
      const Color(0xFF00BFA5), // Turquesa
      const Color(0xFFE64A19), // Naranja
    ];

    return Container(
      width: 300, // Ancho de cada tarjeta (estilo banner apaisado)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Placeholder de la imagen
          Container(
            width: 120,
            decoration: BoxDecoration(
              color: placeholderColors[index % placeholderColors.length],
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.image_outlined, color: Colors.white54, size: 40),
          ),
          // Contenido de texto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50), // Verde de "Sorteo"
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Sorteo',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gana en grande',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Haz 3 pagos en comercios',
                    style: TextStyle(color: Color(0xFF757575), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}