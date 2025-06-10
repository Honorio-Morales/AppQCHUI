import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// TO DO : CAMBIAR COLORES y el boton de siguiente.
void main() {
  runApp(
    MaterialApp(
      home: const Level3Screen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Nunito',
      ),
    ),
  );
}

class Level3Screen extends StatefulWidget {
  const Level3Screen({super.key});

  @override
  _Level3ScreenState createState() => _Level3ScreenState();
}

class _Level3ScreenState extends State<Level3Screen> {
  int currentExerciseIndex = 0;
  int correctAnswers = 0;
  String? selectedOption;
  bool exerciseCompleted = false;
  bool showResults = false;
  int exerciseKey = 0;

  final List<Map<String, dynamic>> level3Exercises = [
    {'title': '¿Cómo se dice "Yo" en quechua?', 'options': ['Pay', 'Qam', 'Ñuqa'], 'answer': 'Ñuqa'},
    {'title': '¿Qué significa el pronombre "Qamkuna"?', 'options': ['Ellos / Ellas', 'Ustedes', 'Nosotros'], 'answer': 'Ustedes'},
    {'title': 'Une el pronombre con su significado: Pay = ?', 'options': ['Tú', 'Él / Ella', 'Yo'], 'answer': 'Él / Ella'},
    {'title': 'Si hablamos JUNTOS, usamos "nosotros inclusivo". ¿Cuál es?', 'options': ['Ñuqayku', 'Paykuna', 'Ñuqanchik'], 'answer': 'Ñuqanchik'},
  ];

  static const Color bgColor = Color(0xFF1D2335);
  static const Color cardColor = Color(0xFF2B324D);
  static const Color primaryColor = Color(0xFF4A80F0);
  static const Color correctColor = Color(0xFF3EDD9B);
  static const Color incorrectColor = Color(0xFFF04A4A);

  void submitAnswer(String selected) {
    if (exerciseCompleted) return;
    setState(() {
      exerciseCompleted = true;
      selectedOption = selected;
      if (selected == level3Exercises[currentExerciseIndex]['answer']) {
        correctAnswers++;
      }
    });
  }

  void nextExercise() {
    setState(() {
      if (currentExerciseIndex < level3Exercises.length - 1) {
        currentExerciseIndex++;
        selectedOption = null;
        exerciseCompleted = false;
        exerciseKey++;
      } else {
        showResults = true;
      }
    });
  }

  void retryLevel() {
    setState(() {
      currentExerciseIndex = 0;
      correctAnswers = 0;
      selectedOption = null;
      exerciseCompleted = false;
      showResults = false;
      exerciseKey = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: 500.ms,
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: showResults ? _buildResultsView() : _buildExerciseView(),
        ),
      ),
    );
  }

  Widget _buildExerciseView() {
    final exercise = level3Exercises[currentExerciseIndex];
    double progress = (currentExerciseIndex + 1) / level3Exercises.length;

    return Padding(
      key: ValueKey(currentExerciseIndex),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NIVEL 3: PRONOMBRES', style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: cardColor,
              valueColor: const AlwaysStoppedAnimation(primaryColor),
            ),
          ).animate().slideX(duration: 400.ms, curve: Curves.easeOut),
          const SizedBox(height: 40),

          Text(
            exercise['title'],
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 30),

          Expanded(
            child: Column(
              key: ValueKey(exerciseKey),
              children: (exercise['options'] as List<String>).map((option) => _buildOptionTile(option)).toList(),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.5, duration: 400.ms),
          ),

          if (exerciseCompleted)
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward_ios),
                label: Text(
                  currentExerciseIndex < level3Exercises.length - 1 ? 'Siguiente' : 'Ver Resultados',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: nextExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ).animate().scale(delay: 200.ms),
            )
        ],
      ),
    );
  }
  
  Widget _buildOptionTile(String option) {
    bool isSelected = selectedOption == option;
    Color color = cardColor;
    IconData? icon;

    if (exerciseCompleted) {
      if (option == level3Exercises[currentExerciseIndex]['answer']) {
        color = correctColor;
        icon = Icons.check_circle;
      } else if (isSelected) {
        color = incorrectColor;
        icon = Icons.cancel;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => submitAnswer(option),
        child: AnimatedContainer(
          duration: 300.ms,
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            border: isSelected && !exerciseCompleted ? Border.all(color: primaryColor, width: 3) : null,
          ),
          child: Row(
            children: [
              Expanded(child: Text(option, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
              if (icon != null) Icon(icon, color: Colors.white).animate().scale()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    double score = correctAnswers / level3Exercises.length;
    String message;
    IconData icon;
    Color iconColor;
    
    if (score == 1.0) {
      message = '¡Excelente! ¡Dominas los pronombres!';
      icon = Icons.workspace_premium;
      iconColor = Colors.amber;
    } else if (score >= 0.5) {
      message = '¡Buen trabajo! Sigue practicando.';
      icon = Icons.thumb_up_alt;
      iconColor = correctColor;
    } else {
      message = '¡No te rindas! La práctica hace al maestro.';
      icon = Icons.sentiment_very_dissatisfied;
      iconColor = incorrectColor;
    }

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, size: 120, color: iconColor)
              .animate(onPlay: (controller) => controller.repeat())
              .shake(hz: 2, duration: 400.ms, rotation: 0.05)
              .then()
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 600.ms)
              .then()
              .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 600.ms),

          const SizedBox(height: 30),
          Text(
            'Completado',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9)),
          ).animate().fadeIn().slideY(begin: 0.5),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7)),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5),
          const SizedBox(height: 40),
          Text(
            'Puntaje: $correctAnswers / ${level3Exercises.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ).animate().fadeIn(delay: 400.ms).scale(),
          const SizedBox(height: 50),

          ElevatedButton(
            onPressed: retryLevel,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Intentar de Nuevo'),
          ).animate().slideY(begin: 2, delay: 600.ms),
        ],
      ),
    );
  }
}