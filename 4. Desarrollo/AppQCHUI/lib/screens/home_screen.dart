import 'package:flutter/material.dart';
import 'package:AppQCHUI/screens/dictionary_screen.dart';
import 'package:AppQCHUI/screens/questions_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprende Quechua'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navegar a login/registro
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/images/qchui.png',
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
           
            ElevatedButton.icon(
              icon: const Icon(Icons.book, size: 24),
              label: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'DICCIONARIO QUECHUA-ESPAÑOL',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
           
            OutlinedButton.icon(
              icon: const Icon(Icons.quiz, size: 24),
              label: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'PRACTICA CON EJERCICIOS',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  QuestionsScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
           
            const Spacer(),
           
            TextButton(
              onPressed: () {
                // Acción rápida
              },
              child: const Text('Explora contenido sin registrar'),
            ),
          ],
        ),
      ),
    );
  }
}