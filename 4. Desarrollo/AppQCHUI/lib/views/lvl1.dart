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

class _Level1ScreenState extends State<Level1Screen> {
  List<Map<String, dynamic>> _exercises = [];
  List<bool> _completedExercises = [];
  double _currentProgress = 0.0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _loadUserProgress();
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
          final exerciseId = _exercises[i]['id'];
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

  Future<void> _completeExercise(int exerciseIndex) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _completedExercises[exerciseIndex] = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('user_exercises')
          .doc(user.uid)
          .set({
            _exercises[exerciseIndex]['id']: true,
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
      appBar: AppBar(
        title: const Text('Nivel 1'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${(_currentProgress * 100).toStringAsFixed(0)}% completado',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _currentProgress,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            color: Colors.redAccent,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                final isCompleted = _completedExercises[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise['question'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(
                          exercise['options'].length,
                          (optionIndex) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                backgroundColor: isCompleted
                                    ? (optionIndex == exercise['correctAnswer']
                                        ? Colors.green
                                        : Colors.grey[200])
                                    : Theme.of(context).primaryColor,
                              ),
                              onPressed: isCompleted
                                  ? null
                                  : () {
                                      if (optionIndex == exercise['correctAnswer']) {
                                        _completeExercise(index);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Respuesta incorrecta, intenta nuevamente'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    },
                              child: Text(
                                exercise['options'][optionIndex],
                                style: TextStyle(
                                  color: isCompleted && 
                                         optionIndex == exercise['correctAnswer']
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isCompleted)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Correcto!',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}