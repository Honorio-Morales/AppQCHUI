import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información sobre QCHUI',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 10),
            const Text(
              'QCHUI es una aplicación diseñada para ayudar a aprender y difundir el idioma quechua. '
              'Aquí podrás encontrar un diccionario, responder preguntas comunes y participar en la comunidad.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Características:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.book, color: Colors.orange),
                SizedBox(width: 10),
                Text('Diccionario interactivo español-quechua'),
              ],
            ),
            Row(
              children: const [
                Icon(Icons.question_answer, color: Colors.orange),
                SizedBox(width: 10),
                Text('Respuestas a preguntas frecuentes'),
              ],
            ),
            Row(
              children: const [
                Icon(Icons.people, color: Colors.orange),
                SizedBox(width: 10),
                Text('Foro de comunidad para compartir experiencias'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
