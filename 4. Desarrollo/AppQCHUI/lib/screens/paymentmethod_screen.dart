import 'package:flutter/material.dart';
import 'package:AppQCHUI/widgets/animated_button.dart';
import 'donationsuccess_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final int amount;

  const PaymentMethodScreen({super.key, required this.amount});

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _selectedMethod = 0; // 0: Tarjeta, 1: PayPal, 2: Transferencia

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Método de Pago'),
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
            // Resumen de donación
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1FAEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Monto a donar:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '\$${widget.amount}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE63946),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            const Text(
              'Selecciona tu método de pago:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 15),
            
            // Métodos de pago
            _buildPaymentMethod(
              icon: Icons.credit_card,
              title: 'Tarjeta de crédito/débito',
              isSelected: _selectedMethod == 0,
              onTap: () => setState(() => _selectedMethod = 0),
            ),
            _buildPaymentMethod(
              icon: Icons.payment,
              title: 'PayPal',
              isSelected: _selectedMethod == 1,
              onTap: () => setState(() => _selectedMethod = 1),
            ),
            _buildPaymentMethod(
              icon: Icons.account_balance,
              title: 'Transferencia bancaria',
              isSelected: _selectedMethod == 2,
              onTap: () => setState(() => _selectedMethod = 2),
            ),
            
            const Spacer(),
            AnimatedButton(
              text: "DONAR \$${widget.amount}",
              onPressed: () {
                // Procesar el pago
                _showConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE63946).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFE63946) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFE63946) : const Color(0xFF1D3557)),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFE63946) : const Color(0xFF1D3557),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFE63946)),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Donación'),
        content: Text(
          '¿Estás seguro de donar \$${widget.amount} a QCHUI?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessScreen(context);
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Color(0xFFE63946)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DonationSuccessScreen(amount: widget.amount),
      ),
    );
  }
}