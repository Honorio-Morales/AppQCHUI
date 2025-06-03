import 'package:flutter/material.dart';
import 'package:qchui/widgets/animated_button.dart';

class DonationSuccessScreen extends StatelessWidget {
  final int amount;

  const DonationSuccessScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFFE63946),
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Donación exitosa!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D3557),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Gracias por tu donación de \$$amount',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Tu contribución nos ayuda a seguir difundiendo el idioma quechua.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              AnimatedButton(
                text: "VOLVER AL INICIO",
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}