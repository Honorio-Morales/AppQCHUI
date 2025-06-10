import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qchui/screens/activities_screen.dart';

class Level1Screen extends StatefulWidget {
  const Level1Screen({super.key});

  @override
  State<Level1Screen> createState() => _Level1ScreenState();
}

class _Level1ScreenState extends State<Level1Screen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _exercises = [];
  List<bool> _completedExercises = [];
  double _currentProgress = 0.0;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Estados del juego
  GameState _gameState = GameState.instructions;
  int _currentExerciseIndex = 0;
  int _countdown = 3;
  
  // Animaciones
  late AnimationController _countdownController;
  late AnimationController _cardController;
  late AnimationController _feedbackController;
  
  late Animation<double> _countdownAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _feedbackAnimation;
  
  Color _feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadExercises();
    _loadUserProgress();
  }

  void _initializeAnimations() {
    _countdownController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _countdownAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _countdownController, curve: Curves.elasticOut),
    );
    
    _cardAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );
    
    _feedbackAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _cardController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('ejercicios')
          .doc('nivel_1')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _exercises = List<Map<String, dynamic>>.from(data['ejercicios']);
          _completedExercises = List.filled(_exercises.length, false);
        });
      } else {
        setState(() {
          _errorMessage = 'No se encontraron ejercicios para este nivel';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error cargando ejercicios: ${e.toString()}';
      });
    }
  }

  Future<void> _loadUserProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Usuario no autenticado';
        _isLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_exercises')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        for (int i = 0; i < _exercises.length; i++) {
          // Manejar IDs nulos o crear uno por defecto
          final exerciseId = _exercises[i]['id']?.toString() ?? 'exercise_$i';
          if (data.containsKey(exerciseId)) {
            _completedExercises[i] = data[exerciseId] == true;
          }
        }
        _updateProgress();
      }
    } catch (e) {
      print('Error loading user progress: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateProgress() {
    final completedCount = _completedExercises.where((e) => e).length;
    final newProgress = _exercises.isEmpty ? 0.0 : completedCount / _exercises.length;
    
    setState(() {
      _currentProgress = newProgress;
    });

    // Actualizar progreso global
    Provider.of<LevelProgress>(context, listen: false)
        .updateProgress(0, newProgress);
  }

  void _startGame() {
    setState(() {
      _gameState = GameState.countdown;
      _countdown = 3;
    });
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      setState(() {
        _countdown = i;
      });
      _countdownController.reset();
      _countdownController.forward();
      await Future.delayed(const Duration(seconds: 1));
    }
    
    setState(() {
      _gameState = GameState.playing;
      _currentExerciseIndex = _getNextIncompleteExercise();
    });
    _cardController.forward();
  }

  int _getNextIncompleteExercise() {
    for (int i = 0; i < _completedExercises.length; i++) {
      if (!_completedExercises[i]) {
        return i;
      }
    }
    return 0; // Fallback
  }

  Future<void> _answerQuestion(int selectedOptionIndex) async {
    final exercise = _exercises[_currentExerciseIndex];
    final isCorrect = selectedOptionIndex == exercise['correctAnswer'];
    
    setState(() {
      _feedbackColor = isCorrect ? const Color(0xFF00FF41) : const Color(0xFFB00020);
    });
    
    _feedbackController.forward();
    
    if (isCorrect) {
      await _completeExercise(_currentExerciseIndex);
      
      // Esperar un momento para mostrar el feedback
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Verificar si hay más ejercicios
      final nextExercise = _getNextIncompleteExercise();
      if (nextExercise != _currentExerciseIndex || 
          _completedExercises.every((e) => e)) {
        // Pasar al siguiente ejercicio o terminar
        if (_completedExercises.every((e) => e)) {
          setState(() {
            _gameState = GameState.completed;
          });
        } else {
          setState(() {
            _currentExerciseIndex = nextExercise;
          });
          _cardController.reset();
          _cardController.forward();
        }
      }
    } else {
      // Esperar un momento para mostrar el feedback de error
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    
    _feedbackController.reset();
    setState(() {
      _feedbackColor = Colors.transparent;
    });
  }

  Future<void> _completeExercise(int exerciseIndex) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _completedExercises[exerciseIndex] = true;
    });

    try {
      // Asegurar que el ejercicio tenga un ID válido
      final exerciseId = _exercises[exerciseIndex]['id']?.toString() ?? 'exercise_${exerciseIndex}';
      
      await FirebaseFirestore.instance
          .collection('user_exercises')
          .doc(user.uid)
          .set({
            exerciseId: true,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      _updateProgress();
    } catch (e) {
      setState(() {
        _completedExercises[exerciseIndex] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error guardando progreso: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nivel 1')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B6B),
              Color(0xFFEE4444),
            ],
          ),
        ),
        child: SafeArea(
          child: _buildGameContent(),
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    switch (_gameState) {
      case GameState.instructions:
        return _buildInstructionsCard();
      case GameState.countdown:
        return _buildCountdownScreen();
      case GameState.playing:
        return _buildGameCard();
      case GameState.completed:
        return _buildCompletedScreen();
    }
  }

  Widget _buildInstructionsCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.quiz,
                  size: 80,
                  color: Color(0xFFEE4444),
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡Bienvenido al Nivel 1!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Instrucciones del juego:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '• Responde las preguntas seleccionando la opción correcta\n'
                  '• Cada respuesta correcta te dará puntos\n'
                  '• Las respuestas incorrectas no avanzan\n'
                  '• Completa todos los ejercicios para pasar al siguiente nivel',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                LinearProgressIndicator(
                  value: _currentProgress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFFEE4444),
                ),
                const SizedBox(height: 8),
                Text(
                  'Progreso: ${(_currentProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    '¡Comenzar!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownScreen() {
    return Center(
      child: AnimatedBuilder(
        animation: _countdownAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _countdownAnimation.value,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _countdown.toString(),
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEE4444),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameCard() {
    if (_currentExerciseIndex >= _exercises.length) {
      return _buildCompletedScreen();
    }

    final exercise = _exercises[_currentExerciseIndex];

    return AnimatedBuilder(
      animation: _feedbackAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _feedbackColor.withOpacity(_feedbackAnimation.value * 0.8),
                blurRadius: 30,
                spreadRadius: 8,
              ),
              if (_feedbackAnimation.value > 0)
                BoxShadow(
                  color: _feedbackColor.withOpacity(_feedbackAnimation.value * 0.4),
                  blurRadius: 50,
                  spreadRadius: 15,
                ),
            ],
          ),
          child: ScaleTransition(
            scale: _cardAnimation,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: _feedbackColor.withOpacity(_feedbackAnimation.value * 0.9),
                  width: 6,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header con progreso
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pregunta ${_currentExerciseIndex + 1} de ${_exercises.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEE4444),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${(_currentProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Pregunta
                    Text(
                      exercise['question'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Opciones
                    Expanded(
                      child: ListView.builder(
                        itemCount: exercise['options'].length,
                        itemBuilder: (context, optionIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ElevatedButton(
                              onPressed: () => _answerQuestion(optionIndex),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF333333),
                                minimumSize: const Size(double.infinity, 60),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(
                                    color: Color(0xFFE0E0E0),
                                    width: 2,
                                  ),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                exercise['options'][optionIndex],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡Felicitaciones!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Has completado el Nivel 1',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 232, 102, 102),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum GameState {
  instructions,
  countdown,
  playing,
  completed,
}
