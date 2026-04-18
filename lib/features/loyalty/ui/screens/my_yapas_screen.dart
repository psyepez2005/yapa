import 'package:flutter/material.dart';

class MyYapasScreen extends StatelessWidget {
  const MyYapasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Yapas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Aquí verás tus beneficios listos para usar',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Text(
              '(Pantalla en construcción)',
              style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}