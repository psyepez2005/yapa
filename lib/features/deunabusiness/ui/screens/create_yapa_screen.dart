import 'package:flutter/material.dart';
import 'package:yapa/core/services/merchant_service.dart';

class CreateYapaScreen extends StatefulWidget {
  const CreateYapaScreen({super.key});

  @override
  State<CreateYapaScreen> createState() => _CreateYapaScreenState();
}

class _CreateYapaScreenState extends State<CreateYapaScreen> {
  final _nameCtrl = TextEditingController();

  final List<double> _valueOptions = [0.50, 1.00, 2.00, 3.00];
  double _selectedValue = 1.00;

  final List<double> _minPurchaseOptions = [3.00, 5.00, 10.00, 15.00];
  double _selectedMinPurchase = 5.00;

  final List<int> _quantityOptions = [1, 5, 10, 20, 50];
  int _selectedQuantity = 1;

  final List<_AudienceOption> _audiences = [
    _AudienceOption('todos', 'Todos', Icons.groups, 'Cualquier cliente'),
    _AudienceOption('nuevos', 'Nuevos', Icons.person_add, 'Primera vez en tu negocio'),
    _AudienceOption('frecuentes', 'Frecuentes', Icons.favorite, 'Vuelven seguido'),
    _AudienceOption('perdidos', 'Recuperar', Icons.replay, 'Hace tiempo no vienen'),
  ];
  String _selectedAudience = 'todos';

  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _createYapa() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ponle un nombre a tu Yapa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final rnd = DateTime.now().millisecondsSinceEpoch.toString();
      final prefix = name.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      final code = '${prefix.substring(0, prefix.length.clamp(0, 4))}${rnd.substring(rnd.length - 4)}';

      await MerchantService().createCoupon(
        name: name,
        value: _selectedValue,
        minimumPurchase: _selectedMinPurchase,
        code: code,
        expiresAt: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        quantity: _selectedQuantity,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Color(0xFF0A9E8F), size: 50),
                ),
                const SizedBox(height: 20),
                const Text(
                  '¡Yapa creada!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF38106D)),
                ),
                const SizedBox(height: 8),
                Text(
                  '"$name" ya est\u00e1 lista.\nTus clientes pueden recibirla.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A1587),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Perfecto', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } on MerchantException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4A1587)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crear una Yapa',
          style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF4A1587),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        onTap: (index) {
          if (index != 2) {
            Navigator.of(context).pop();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Mi Caja'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Yapa'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Men\u00fa'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              icon: Icons.edit_outlined,
              title: '\u00BFC\u00F3mo se llama tu Yapa?',
              subtitle: 'Un nombre f\u00E1cil para que la reconozcan',
              child: TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Ej: Descuento del Viernes',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF4A1587), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              icon: Icons.local_offer_outlined,
              title: '\u00BFCu\u00E1nto le das de yapa?',
              subtitle: 'Descuento que recibe tu cliente',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _valueOptions.map((v) => _buildChip(
                  label: '\$${v.toStringAsFixed(2)}',
                  selected: _selectedValue == v,
                  onTap: () => setState(() => _selectedValue = v),
                )).toList(),
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              icon: Icons.shopping_cart_outlined,
              title: '\u00BFCompra m\u00EDnima para aplicar?',
              subtitle: 'El cliente gasta al menos esta cantidad',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _minPurchaseOptions.map((v) => _buildChip(
                  label: '\$${v.toStringAsFixed(2)}',
                  selected: _selectedMinPurchase == v,
                  onTap: () => setState(() => _selectedMinPurchase = v),
                )).toList(),
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              icon: Icons.format_list_numbered,
              title: '¿Cuántos cupones emites?',
              subtitle: 'Se descontará \$${(_selectedValue * _selectedQuantity).toStringAsFixed(2)} de tu saldo',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _quantityOptions.map((q) => _buildChip(
                  label: q == 1 ? '1 cupón' : '$q cupones',
                  selected: _selectedQuantity == q,
                  onTap: () => setState(() => _selectedQuantity = q),
                )).toList(),
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              icon: Icons.people_outline,
              title: '\u00BFA qui\u00E9n va dirigida?',
              subtitle: 'Elige qu\u00E9 clientes la reciben',
              child: Column(
                children: _audiences.map((a) => _buildAudienceTile(a)).toList(),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Resumen de tu Yapa',
                    style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem('Descuento', '\$${_selectedValue.toStringAsFixed(2)}'),
                      Container(width: 1, height: 36, color: Colors.grey.shade200),
                      _summaryItem('Cantidad', '$_selectedQuantity'),
                      Container(width: 1, height: 36, color: Colors.grey.shade200),
                      _summaryItem('Total', '\$${(_selectedValue * _selectedQuantity).toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Vence autom\u00E1ticamente en 30 d\u00EDas',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A1587),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: _loading ? null : _createYapa,
                      icon: _loading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle, size: 24, color: Colors.white),
                      label: Text(
                        _loading ? 'Creando...' : 'Crear Yapa',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Color(0xFF4A1587), fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3E5F5) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF4A1587) : const Color(0xFFE0E0E0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? const Color(0xFF4A1587) : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildAudienceTile(_AudienceOption option) {
    final selected = _selectedAudience == option.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAudience = option.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3E5F5) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF4A1587) : const Color(0xFFE0E0E0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF4A1587).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                option.icon,
                color: selected ? const Color(0xFF4A1587) : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: selected ? const Color(0xFF4A1587) : Colors.black87,
                    ),
                  ),
                  Text(
                    option.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? const Color(0xFF6B2FA0) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Color(0xFF4A1587), size: 22),
          ],
        ),
      ),
    );
  }
}

class _AudienceOption {
  final String id;
  final String label;
  final IconData icon;
  final String description;
  const _AudienceOption(this.id, this.label, this.icon, this.description);
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A1587).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF4A1587), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
