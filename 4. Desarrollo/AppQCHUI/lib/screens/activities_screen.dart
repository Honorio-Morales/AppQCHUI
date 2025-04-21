import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int? selectedLevel;
  int currentExerciseIndex = 0;
  Map<int, int> correctAnswers = {}; // nivel -> aciertos
  Map<int, int> totalAnswers = {}; // nivel -> intentos

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anon';

  final Map<int, List<Map<String, dynamic>>> levelExercises = {
    1: [
      {
        'title': 'Selecciona el color que corresponde a "puka"',
        'options': ['Rojo', 'Azul', 'Verde'],
        'answer': 'Rojo',
      },
      {
        'title': '¿Qué come el perro?',
        'options': ['Hueso', 'Zapato', 'Piedra'],
        'answer': 'Hueso',
      },
      {
        'title': 'Une: Puka = ?',
        'options': ['Rojo', 'Amarillo', 'Blanco'],
        'answer': 'Rojo',
      },
      {
        'title': '¿Qué color es "q’omer"?',
        'options': ['Verde', 'Negro', 'Rojo'],
        'answer': 'Verde',
      },
    ],
  };

  String? selectedOption;
  bool exerciseCompleted = false;
  bool showResults = false;

  void submitAnswer(String selected, String correct) {
    if (!exerciseCompleted) {
      setState(() {
        totalAnswers[selectedLevel!] = (totalAnswers[selectedLevel!] ?? 0) + 1;
        if (selected == correct) {
          correctAnswers[selectedLevel!] = (correctAnswers[selectedLevel!] ?? 0) + 1;
        }
        exerciseCompleted = true;
      });
    }
  }

  void nextExercise() {
    setState(() {
      if (currentExerciseIndex < levelExercises[selectedLevel!]!.length - 1) {
        currentExerciseIndex++;
        exerciseCompleted = false;
        selectedOption = null;
      } else {
        showResults = true;
      }
    });
  }

  void resetLevel() {
    setState(() {
      currentExerciseIndex = 0;
      exerciseCompleted = false;
      selectedOption = null;
      showResults = false;
      correctAnswers[selectedLevel!] = 0;
      totalAnswers[selectedLevel!] = 0;
    });
  }

  Widget buildLevelButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(5, (index) {
        int level = index + 1;
        bool isSelected = selectedLevel == level;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: isSelected ? Matrix4.translationValues(0, -10, 0) : Matrix4.identity(),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                selectedLevel = level;
                resetLevel();
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: isSelected ? Colors.orange : const Color.fromARGB(255, 255, 255, 255),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isSelected ? 10 : 2,
            ),
            child: Text('Nivel $level'),
          ).animate().fadeIn(duration: 500.ms).scale(),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercises = selectedLevel != null ? levelExercises[selectedLevel] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios de Quechua'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecciona un nivel para comenzar:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(child: buildLevelButtons()),
            const SizedBox(height: 24),
            if (selectedLevel != null && showResults) ...[
              Text(
                'Resultados del Nivel $selectedLevel',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Correctas: ${correctAnswers[selectedLevel] ?? 0}'),
              Text('Total: ${totalAnswers[selectedLevel] ?? 0}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedLevel = null;
                    showResults = false;
                  });
                },
                child: const Text('Volver a niveles'),
              ),
            ] else if (selectedLevel != null && exercises != null) ...[
              Text(
                'Ejercicio ${currentExerciseIndex + 1} de ${exercises.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                exercises[currentExerciseIndex]['title'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...exercises[currentExerciseIndex]['options']
                  .map<Widget>(
                    (option) => RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: selectedOption,
                      onChanged: exerciseCompleted
                          ? null
                          : (value) {
                              setState(() {
                                selectedOption = value;
                              });
                            },
                    ),
                  )
                  .toList(),
              const SizedBox(height: 12),
              if (!exerciseCompleted)
                ElevatedButton(
                  onPressed: selectedOption != null
                      ? () => submitAnswer(
                            selectedOption!,
                            exercises[currentExerciseIndex]['answer'],
                          )
                      : null,
                  child: const Text('Comprobar'),
                ),
              if (exerciseCompleted)
                Column(
                  children: [
                    Text(
                      selectedOption == exercises[currentExerciseIndex]['answer']
                          ? '¡Correcto!'
                          : 'Incorrecto. La respuesta era: ${exercises[currentExerciseIndex]['answer']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedOption == exercises[currentExerciseIndex]['answer']
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: nextExercise,
                      child: const Text('Siguiente'),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}