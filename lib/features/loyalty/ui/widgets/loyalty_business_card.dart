import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'yapa_step_indicator.dart';

class LoyaltyBusinessCard extends StatefulWidget {
  final String businessName;
  final String category;
  final String location;
  final String tierName; 
  final String cashbackPercentage; 
  final String minPurchaseAmount; 
  final int visits;
  final double progress;
  final String nextLevel;
  final int purchasesNeeded;
  final IconData businessIcon;
  final int currentYapas;
  final VoidCallback? onTap;

  const LoyaltyBusinessCard({
    super.key,
    required this.businessName,
    required this.category,
    required this.location,
    required this.tierName,
    required this.cashbackPercentage,
    required this.minPurchaseAmount,
    required this.visits,
    required this.progress,
    required this.nextLevel,
    required this.purchasesNeeded,
    required this.businessIcon,
    required this.currentYapas,
    this.onTap,
  });

  @override
  State<LoyaltyBusinessCard> createState() => _LoyaltyBusinessCardState();
}

class _LoyaltyBusinessCardState extends State<LoyaltyBusinessCard> {
  bool _isExpanded = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color tierColor;
    // La variable tierBgColor ya no se usa para el badge, pero la dejamos por si decides volver a usarla
    Color tierBgColor; 

    switch (widget.tierName.toLowerCase()) {
      case 'oro':
        tierColor = const Color(0xFFF57F17);
        tierBgColor = const Color(0xFFFFF9C4);
        break;
      case 'plata':
        tierColor = const Color(0xFF78909C);
        tierBgColor = const Color(0xFFECEFF1);
        break;
      case 'bronce':
      default:
        tierColor = const Color(0xFFCE8946);
        tierBgColor = const Color(0xFFFBE9E7);
        break;
    }

    final isActive = _isExpanded || _isHovered;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF4A1587) : Colors.grey.shade200,
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onHover: (value) {
            setState(() {
              _isHovered = value;
            });
          },
          onTap: widget.onTap ??
              () => context.pushNamed(
                    'business_detail',
                    extra: {
                      'name': widget.businessName,
                      'icon': widget.businessIcon,
                      'tier': widget.tierName,
                      'cashback': widget.cashbackPercentage,
                      'currentPoints': widget.currentYapas,
                      'targetPoints': 5,
                    },
                  ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.businessIcon,
                        color: const Color(0xFF4A1587),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.businessName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          // ✅ Solo mostramos la categoría (quitamos la ubicación)
                          Text(
                            widget.category,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    // ✅ Dejamos solo el contador de visitas
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(
                        '${widget.visits} visitas',
                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Text(
                  'Yapas ganadas en este local',
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                YapaStepIndicator(
                  currentSteps: widget.currentYapas,
                  totalSteps: 5,
                ),

                const SizedBox(height: 16),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: widget.progress,
                    backgroundColor: Colors.grey.shade200,
                    color: tierColor,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                
                // ✅ Nueva fila minimalista bajo la barra de progreso
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.tierName, // Solo dice "Bronce", "Plata", etc.
                      style: TextStyle(
                        color: tierColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(widget.progress * 100).toInt()}%', // Solo el porcentaje
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Sección "Pasa la Yapa" (Se mantiene intacta)
                if (_isExpanded) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAEDFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF3E5F5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A1587),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.handshake,
                            color: Color(0xFFFBC02D),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pasa la Yapa',
                                style: TextStyle(
                                  color: Color(0xFF4A1587),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Invita a un vecino a ${widget.businessName} y ambos ganan \$0.50',
                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Color(0xFF4A1587)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}