import 'package:flutter/material.dart';

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
    Color tierBgColor;

    switch (widget.tierName.toLowerCase()) {
      case 'oro':
        tierColor = const Color(0xFFF57F17); // Dorado
        tierBgColor = const Color(0xFFFFF9C4);
        break;
      case 'plata':
        tierColor = const Color(0xFF78909C); // Plateado
        tierBgColor = const Color(0xFFECEFF1);
        break;
      case 'bronce':
      default:
        tierColor = const Color(0xFFCE8946); // Bronce exacto de la imagen
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
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
            debugPrint('Clic en el negocio: ${widget.businessName}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
                      child: Icon(widget.businessIcon, color: const Color(0xFF4A1587), size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.businessName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${widget.category} · ${widget.location}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: tierBgColor, borderRadius: BorderRadius.circular(15)),
                            child: Text(
                              '${widget.tierName} ${widget.cashbackPercentage}', 
                              style: TextStyle(color: tierColor, fontSize: 12, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Yapa: \$2.40', 
                          style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 15)
                        ),
                        const SizedBox(height: 4),
                        Text('${widget.visits} visitas', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ],
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
                const SizedBox(height: 12),
                
                if (widget.purchasesNeeded > 0)
                  Row(
                    children: [
                      Text('Progreso ${(widget.progress * 100).toInt()}%  ➔  ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      Expanded(
                        child: Text(
                          'Te ${widget.purchasesNeeded == 1 ? "falta" : "faltan"} ${widget.purchasesNeeded} ${widget.purchasesNeeded == 1 ? "compra" : "compras"} para Yapa ${widget.nextLevel}', 
                          style: TextStyle(color: tierColor, fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      const Text('Progreso 100%  ➔  ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Expanded(
                        child: Text(
                          '¡Has alcanzado el ${widget.nextLevel}!', 
                          style: TextStyle(color: tierColor, fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                if (_isExpanded) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAEDFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF3E5F5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: const BoxDecoration(color: Color(0xFF4A1587), shape: BoxShape.circle),
                          child: const Icon(Icons.handshake, color: Color(0xFFFBC02D), size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pasa la Yapa', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Invita a un vecino a ${widget.businessName} y ambos ganan \$0.50', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF4A1587)),
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