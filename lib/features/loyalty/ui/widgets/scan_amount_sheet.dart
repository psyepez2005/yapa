import 'package:flutter/material.dart';
import 'package:yapa/core/models/loyalty_profile.dart';
import 'package:yapa/core/services/loyalty_service.dart';
import 'package:yapa/core/services/scan_service.dart';
import 'package:yapa/features/loyalty/ui/widgets/scan_result_sheet.dart';

class ScanAmountSheet extends StatefulWidget {
  final String merchantId;
  final VoidCallback onDone;

  const ScanAmountSheet({
    super.key,
    required this.merchantId,
    required this.onDone,
  });

  @override
  State<ScanAmountSheet> createState() => _ScanAmountSheetState();
}

class _ScanAmountSheetState extends State<ScanAmountSheet> {
  String _amount = '';
  String? _selectedCouponId;
  List<ActiveYapa> _yapas = [];
  String _merchantName = 'Negocio';
  bool _submitting = false;
  bool _loadingYapas = true;

  @override
  void initState() {
    super.initState();
    _loadYapas();
  }

  Future<void> _loadYapas() async {
    try {
      final entries = await LoyaltyService().fetchProfile();
      final match = entries.where((e) => e.merchantId == widget.merchantId).firstOrNull;
      if (mounted) {
        setState(() {
          _yapas = match?.activeYapas ?? [];
          _merchantName = match?.merchantName ?? 'Negocio';
          _loadingYapas = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingYapas = false);
    }
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == 'delete') {
        if (_amount.isNotEmpty) _amount = _amount.substring(0, _amount.length - 1);
      } else if (key == '.' && _amount.contains('.')) {
        return;
      } else {
        _amount += key;
      }
    });
  }

  double? get _parsedAmount {
    final v = double.tryParse(_amount);
    return (v != null && v > 0) ? v : null;
  }

  Future<void> _submit() async {
    final amount = _parsedAmount;
    if (amount == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      final result = await ScanService().scan(
        merchantId: widget.merchantId,
        amount: amount,
        couponId: _selectedCouponId,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ScanResultSheet(
          result: result,
          merchantName: _merchantName,
          onDone: widget.onDone,
        ),
      );
    } on ScanException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _loadingYapas ? 'Cargando...' : _merchantName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Ingresa el monto de tu compra',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Text(
            _amount.isEmpty ? '\$ 0' : '\$$_amount',
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A1587),
            ),
          ),
          const SizedBox(height: 16),
          if (!_loadingYapas && _yapas.isNotEmpty) ...[
            _YapaSelector(
              yapas: _yapas,
              selectedId: _selectedCouponId,
              onSelect: (id) => setState(
                () => _selectedCouponId = id == _selectedCouponId ? null : id,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildKeypad(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (_parsedAmount != null && !_submitting) ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A1587),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Registrar Pago',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', 'delete'],
    ];
    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              return SizedBox(
                width: 80,
                height: 48,
                child: InkWell(
                  onTap: () => _onKeyTap(key),
                  borderRadius: BorderRadius.circular(24),
                  child: Center(
                    child: key == 'delete'
                        ? const Icon(Icons.backspace, color: Color(0xFF4A1587), size: 24)
                        : Text(
                            key,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF4A1587),
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _YapaSelector extends StatelessWidget {
  final List<ActiveYapa> yapas;
  final String? selectedId;
  final void Function(String id) onSelect;

  const _YapaSelector({
    required this.yapas,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usar una Yapa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: yapas.map((yapa) {
              final selected = yapa.id == selectedId;
              return GestureDetector(
                onTap: () => onSelect(yapa.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF00BFA5) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? const Color(0xFF00BFA5) : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        '\$${yapa.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF4A1587),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
