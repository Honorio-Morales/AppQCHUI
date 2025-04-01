import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  // Lista de preguntas frecuentes sobre el idioma quechua.
  final List<String> questions = [
    '¿Cómo se dice "buenos días" en quechua?',
    '¿Cuál es el origen del idioma quechua?',
    '¿Se sigue hablando quechua en la actualidad?',
    '¿Cómo puedo aprender quechua más rápido?',
    '¿Existen diferentes dialectos del quechua?',
  ];

  // Lista de respuestas correspondientes a las preguntas.
  final List<String> answers = [
    'En quechua, "buenos días" se dice "Allin p\'unchay".',
    'El idioma quechua tiene sus orígenes en la región andina de Sudamérica, principalmente en el Imperio Inca.',
    'Sí, el quechua sigue siendo hablado por millones de personas en países como Perú, Bolivia, Ecuador y otros.',
    'Para aprender quechua más rápido, es recomendable practicar con hablantes nativos, usar aplicaciones de aprendizaje y sumergirte en la cultura quechua.',
    'Sí, existen varios dialectos del quechua, como el quechua sureño, el quechua central y otros.',
  ];

  // Índice de la pregunta seleccionada para mostrar la respuesta.
  int? selectedIndex;

  // Función para mover la pregunta al principio de la lista cuando se presiona el ícono.
  void _moveQuestionToTop(int index) {
    setState(() {
      // Mueve la pregunta seleccionada al principio de la lista.
      final String question = questions.removeAt(index); // Elimina la pregunta de su posición actual.
      final String answer = answers.removeAt(index); // Elimina la respuesta correspondiente.
      questions.insert(0, question); // Inserta la pregunta al principio de la lista.
      answers.insert(0, answer); // Inserta la respuesta al principio de la lista.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra de la aplicación.
      appBar: AppBar(
        title: const Text('Preguntas Frecuentes'), // Título de la barra de la aplicación.
      ),
      // Cuerpo de la aplicación.
      body: ListView.builder(
        itemCount: questions.length, // Número de elementos en la lista.
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0), // Espaciado alrededor de cada tarjeta.
            child: Card(
              // Tarjeta que contiene la pregunta y la respuesta.
              child: Column(
                children: [
                  ListTile(
                    // Ícono de la pregunta.
                    leading: GestureDetector(
                      onTap: () {
                        _moveQuestionToTop(index); // Mueve la pregunta al principio al presionar el ícono.
                      },
                      child: Icon(
                        Icons.question_answer,
                        color: selectedIndex == index ? Colors.green : Colors.blue, // Cambia el color del ícono a verde si está seleccionado.
                      ),
                    ),
                    // Texto de la pregunta.
                    title: Text(
                      questions[index],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Estilo del texto.
                    ),
                    // Acción al tocar la pregunta.
                    onTap: () {
                      setState(() {
                        // Si la pregunta ya está seleccionada, la deselecciona.
                        if (selectedIndex == index) {
                          selectedIndex = null;
                        } else {
                          selectedIndex = index; // Selecciona la pregunta actual.
                        }
                      });
                    },
                  ),
                  // Si la pregunta está seleccionada, muestra la respuesta.
                  if (selectedIndex == index)
                    Padding(
                      padding: const EdgeInsets.all(16.0), // Espaciado interno para la respuesta.
                      child: Text(
                        answers[index], // Texto de la respuesta.
                        style: const TextStyle(fontSize: 14), // Estilo del texto.
                      ),
                    )
                        .animate() // Inicia la animación.
                        .fadeIn() // Efecto de desvanecimiento.
                        .slideY(begin: -0.5, end: 0) // Efecto de deslizamiento desde arriba.
                ],
              ),
            ),
          );
        },
     ),
     );
}
}

