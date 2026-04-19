import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MockupPaymentAmountScreen extends StatefulWidget {
  final String merchantId;
  final String merchantName;

  const MockupPaymentAmountScreen({
    super.key,
    required this.merchantId,
    required this.merchantName,
  });

  @override
  State<MockupPaymentAmountScreen> createState() => _MockupPaymentAmountScreenState();
}

class _MockupPaymentAmountScreenState extends State<MockupPaymentAmountScreen> {
  String _amount = '';

  void _onKeypadTap(String key) {
    setState(() {
      if (key == 'delete') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else {
        _amount += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('¿Cuánto quieres pagar?', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go('/mockup'),
            child: const Text('Salir', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFEAD8F7),
              shape: BoxShape.circle,
            ),
            child: Text(
              widget.merchantName.length >= 2
                  ? widget.merchantName.substring(0, 2).toUpperCase()
                  : widget.merchantName.toUpperCase(),
              style: const TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Pagando a', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(widget.merchantName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),

          const SizedBox(height: 40),

          Text(_amount.isEmpty ? '\$0' : '\$$_amount', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w500, color: Color(0xFF4A1587))),

          const Spacer(),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildChip('+ Motivo', isAdd: true),
                const SizedBox(width: 8),
                _buildChip('🍔 Comida'),
                const SizedBox(width: 8),
                _buildChip('💸 Deuda'),
                const SizedBox(width: 8),
                _buildChip('🎉 Entret...'),
              ],
            ),
          ),

          const SizedBox(height: 48),

          _buildKeypad(),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _amount.isNotEmpty ? () {
                  context.pushNamed('payment_confirmation', extra: {
                    'amount': _amount,
                    'merchantId': widget.merchantId,
                    'merchantName': widget.merchantName,
                  });
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _amount.isNotEmpty ? const Color(0xFF4A1587) : Colors.grey.shade300,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('Continuar', style: TextStyle(color: _amount.isNotEmpty ? Colors.white : Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip(String label, {bool isAdd = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isAdd ? const Color(0xFF4A1587) : const Color(0xFF263238),
          fontWeight: isAdd ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      [',', '0', 'delete'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              return SizedBox(
                width: 80,
                height: 50,
                child: InkWell(
                  onTap: () => _onKeypadTap(key),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Center(
                    child: key == 'delete'
                        ? Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4A1587),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          )
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
