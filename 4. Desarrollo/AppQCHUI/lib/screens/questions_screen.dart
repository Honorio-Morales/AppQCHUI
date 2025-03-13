import 'package:flutter/material.dart';

class QuestionsScreen extends StatelessWidget {
  QuestionsScreen({super.key});

  // Lista de preguntas frecuentes sobre el idioma quechua
  final List<String> questions = [
    '¿Cómo se dice "buenos días" en quechua?',
    '¿Cuál es el origen del idioma quechua?',
    '¿Se sigue hablando quechua en la actualidad?',
    '¿Cómo puedo aprender quechua más rápido?',
    '¿Existen diferentes dialectos del quechua?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.question_answer, color: Colors.blue),
                title: Text(
                  questions[index],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
