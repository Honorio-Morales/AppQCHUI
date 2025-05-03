import 'package:flutter/material.dart';
import 'paymentmethod_screen.dart';
import 'package:AppQCHUI/widgets/animated_button.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  int? _selectedAmount;
  final List<int> _amounts = [10, 20, 50, 100, 200];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Donación'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1D3557)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona el monto de tu donación',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tu contribución ayuda a mantener y mejorar nuestra aplicación para la comunidad.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            
            // Selector de montos
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _amounts.map((amount) {
                return ChoiceChip(
                  label: Text('\$$amount'),
                  selected: _selectedAmount == amount,
                  onSelected: (selected) {
                    setState(() {
                      _selectedAmount = selected ? amount : null;
                    });
                  },
                  selectedColor: const Color(0xFFE63946),
                  labelStyle: TextStyle(
                    color: _selectedAmount == amount 
                        ? Colors.white 
                        : const Color(0xFF1D3557),
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            ),
            
            // Monto personalizado
            const SizedBox(height: 20),
            const Text(
              'O ingresa un monto personalizado:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1D3557)),
                ),
                hintText: 'Ej: 75',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _selectedAmount = int.tryParse(value);
                  });
                }
              },
            ),
            
            const Spacer(),
            AnimatedButton(
              text: "CONTINUAR",
              onPressed: _selectedAmount != null
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentMethodScreen(
                            amount: _selectedAmount!,
                          ),
                        ),
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}