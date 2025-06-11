import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qchui/screens/activities_screen.dart';
import '../widgets/animated_button.dart';

// ==========================================================
// PARTE 1: MODELOS Y ENUMS (SIMPLIFICADOS)
// ==========================================================
enum TipoEjercicio { opcionMultiple, verdaderoFalso }

class Ejercicio {
  final String id;
  final TipoEjercicio tipo;
  final String pregunta;
  final List<String> opciones;
  final String respuestaCorrecta;
  bool? fueCorrecto;

  Ejercicio({
    required this.id,
    required this.tipo,
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrecta,
    this.fueCorrecto,
  });

  factory Ejercicio.fromMap(Map<String, dynamic> map) {
    TipoEjercicio tipo;
    switch (map['tipo']) {
      case 'verdaderoFalso':
        tipo = TipoEjercicio.verdaderoFalso;
        break;
      default:
        tipo = TipoEjercicio.opcionMultiple;
    }

    return Ejercicio(
      id: map['id'] ?? 'no-id-${Random().nextInt(1000)}',
      tipo: tipo,
      pregunta: map['pregunta'] ?? 'Sin pregunta',
      opciones: List<String>.from(map['opciones'] ?? []),
      respuestaCorrecta: map['respuestaCorrecta'] ?? '',
    );
  }
}

// Se añade el estado de "instrucciones"
enum ModoJuego { instrucciones, normal, repaso }

// ==========================================================
// PARTE 2: WIDGET PRINCIPAL (StatefulWidget)
// ==========================================================
class Level2Screen extends StatefulWidget {
  const Level2Screen({super.key});

  @override
  _Level2ScreenState createState() => _Level2ScreenState();
}

class _Level2ScreenState extends State<Level2Screen> {
  // --- Colores y Estilos ---
  static const Color colorPrincipal = Color(0xFFE04846);
  static const Color colorFondo = Color(0xFFFFF7F7);
  static const Color colorCorrecto = Colors.green;
  static const Color colorIncorrecto = Colors.red;

  // --- ESTADO CONECTADO A FIREBASE ---
  List<Ejercicio> _ejerciciosActuales = [];
  List<bool> _completedExercises = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // --- Estado del Juego ---
  List<Ejercicio> _ejerciciosFallados = [];
  ModoJuego _modoJuego = ModoJuego.instrucciones; // Inicia en la pantalla de instrucciones
  int _currentIndex = 0;
  bool _respuestaEnviada = false;
  bool _respuestaMostrada = false;
  String? _opcionSeleccionada;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  // ==========================================================
  // PARTE 3: LÓGICA DE FIREBASE Y PROGRESO (SIN CAMBIOS)
  // ==========================================================

  Future<void> _loadExercises() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('ejercicios')
          .doc('nivel_2')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _ejerciciosActuales = (data['ejercicios'] as List)
              .map((ejercicioMap) => Ejercicio.fromMap(ejercicioMap))
              .toList();
          _completedExercises = List.filled(_ejerciciosActuales.length, false);
        });
        await _loadUserProgress();
      } else {
        setState(() => _errorMessage = 'No se encontraron ejercicios para el Nivel 2');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error cargando ejercicios: ${e.toString()}');
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('user_exercises').doc(user.uid).get();

      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          for (int i = 0; i < _ejerciciosActuales.length; i++) {
            final exerciseId = _ejerciciosActuales[i].id;
            if (data.containsKey(exerciseId) && data[exerciseId] == true) {
              _completedExercises[i] = true;
              _ejerciciosActuales[i].fueCorrecto = true;
            }
          }
          _updateProgress();
        });
      }
    } catch (e) {
      print('Error cargando progreso del usuario: $e');
    }
  }

  void _updateProgress() {
    if (!mounted) return;
    final completedCount = _completedExercises.where((e) => e).length;
    final newProgress = _ejerciciosActuales.isEmpty ? 0.0 : completedCount / _ejerciciosActuales.length;
    
    setState(() {}); // Actualiza la UI que depende del progreso

    Provider.of<LevelProgress>(context, listen: false)
        .updateProgress(1, newProgress);
  }

  Future<void> _completeExercise(int exerciseIndex) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _completedExercises[exerciseIndex]) return;

    setState(() => _completedExercises[exerciseIndex] = true);

    try {
      final exerciseId = _ejerciciosActuales[exerciseIndex].id;
      await FirebaseFirestore.instance
          .collection('user_exercises')
          .doc(user.uid)
          .set({ exerciseId: true }, SetOptions(merge: true));
      _updateProgress();
    } catch (e) {
      setState(() => _completedExercises[exerciseIndex] = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando progreso: ${e.toString()}')),
        );
      }
    }
  }
  
  // ==========================================================
  // PARTE 4: LÓGICA DEL JUEGO (SIMPLIFICADA)
  // ==========================================================
  
  void _revisarRespuesta() {
    setState(() {
      final ejercicioActual = _ejerciciosActuales[_currentIndex];
      bool fueCorrecto = _opcionSeleccionada == ejercicioActual.respuestaCorrecta;

      ejercicioActual.fueCorrecto = fueCorrecto;

      if (fueCorrecto) {
        _completeExercise(_currentIndex);
      } else if (_modoJuego == ModoJuego.normal && !_ejerciciosFallados.contains(ejercicioActual)) {
        _ejerciciosFallados.add(ejercicioActual);
      }
      
      _respuestaEnviada = true;
    });
  }

  void _mostrarRespuesta() {
    setState(() {
      final ejercicioActual = _ejerciciosActuales[_currentIndex];
      ejercicioActual.fueCorrecto = false;

      if (_modoJuego == ModoJuego.normal && !_ejerciciosFallados.contains(ejercicioActual)) {
        _ejerciciosFallados.add(ejercicioActual);
      }

      _respuestaMostrada = true;
      _respuestaEnviada = true;
    });
  }

  void _siguientePregunta() {
    if (_currentIndex < _ejerciciosActuales.length - 1) {
      setState(() {
        _currentIndex++;
        _reiniciarEstadoPregunta();
      });
    } else {
      _mostrarDialogoFinal();
    }
  }
  
  void _reiniciarEstadoPregunta() {
    _respuestaEnviada = false;
    _respuestaMostrada = false;
    _opcionSeleccionada = null;
  }

  void _iniciarModoRepaso() {
    Navigator.of(context).pop();
    setState(() {
      _ejerciciosActuales = List.from(_ejerciciosFallados)..shuffle();
      _ejerciciosFallados = [];
      _modoJuego = ModoJuego.repaso;
      _currentIndex = 0;
      _reiniciarEstadoPregunta();
    });
  }
  
  // ==========================================================
  // DIÁLOGO DE RESULTADOS MODERNO Y PROFESIONAL
  // ==========================================================
  void _mostrarDialogoFinal() {
    int correctas = _ejerciciosActuales.where((e) => e.fueCorrecto == true).length;
    int total = _ejerciciosActuales.length;
    bool hayFallos = _modoJuego == ModoJuego.normal && _ejerciciosFallados.isNotEmpty;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          elevation: 16,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hayFallos ? Icons.lightbulb_outline : Icons.star_border_purple500_sharp,
                  color: hayFallos ? Colors.orangeAccent : Colors.amber,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  hayFallos ? '¡Buen Intento!' : '¡Nivel Completado!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: hayFallos ? Colors.orange.shade800 : colorPrincipal,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tu puntuación final es:',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$correctas de $total correctas',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                if (hayFallos)
                  Text(
                    'Tienes ${_ejerciciosFallados.length} preguntas por repasar. ¡No te rindas!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: hayFallos ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text(hayFallos ? 'Salir' : 'Finalizar', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                    if (hayFallos)
                      ElevatedButton(
                        onPressed: _iniciarModoRepaso,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrincipal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Repasar Fallos'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // PARTE 5: WIDGETS DE LA INTERFAZ
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: colorFondo, body: Center(child: CircularProgressIndicator(color: colorPrincipal)));
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorFondo,
        appBar: AppBar(title: const Text('Error', style: TextStyle(color: Colors.white)), backgroundColor: colorPrincipal),
        body: Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!)))
      );
    }
    
    if (_ejerciciosActuales.isEmpty) {
        return Scaffold(
          backgroundColor: colorFondo,
          appBar: AppBar(title: const Text('Nivel 2', style: TextStyle(color: Colors.white)), backgroundColor: colorPrincipal),
          body: const Center(child: Text('No hay ejercicios disponibles para este nivel.'))
        );
    }

    // Lógica para mostrar instrucciones o el juego
    if (_modoJuego == ModoJuego.instrucciones) {
      return _buildInstructionsScreen();
    }

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: Text(_modoJuego == ModoJuego.normal ? 'Nivel 2: Verbos' : 'Repasando Fallos', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: colorPrincipal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProgresoGlobal(),
            const SizedBox(height: 16),
            Text('Pregunta ${_currentIndex + 1} de ${_ejerciciosActuales.length}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: (_currentIndex + 1) / _ejerciciosActuales.length, backgroundColor: colorPrincipal.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(colorPrincipal)),
            const SizedBox(height: 20),
            
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentIndex),
                  child: _buildOpcionMultipleWidget(_ejerciciosActuales[_currentIndex]),
                ),
              ),
            ),
            
            const SizedBox(height: 10),

            if (!_respuestaEnviada)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextButton(
                  onPressed: _mostrarRespuesta,
                  child: Text("Mostrar Respuesta", style: TextStyle(color: Colors.grey[700], decoration: TextDecoration.underline)),
                ),
              ),

            AnimatedButton(
              text: _respuestaEnviada ? 'Siguiente' : 'Revisar',
              onPressed: _respuestaEnviada 
                  ? _siguientePregunta 
                  : _revisarRespuesta,
              enabled: _respuestaEnviada || _opcionSeleccionada != null,
            ),
          ],
        ),
      ),
    );
  }
  
  // ==========================================================
  // PANTALLA DE INSTRUCCIONES
  // ==========================================================
  Widget _buildInstructionsScreen() {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Nivel 2: Verbos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: colorPrincipal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24.0),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_outlined, size: 80, color: colorPrincipal),
                const SizedBox(height: 24),
                const Text(
                  '¡Prepárate para el Nivel 2!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'En este nivel, pondrás a prueba tu conocimiento sobre los verbos en Quechua. ¡Selecciona la opción correcta y demuestra lo que sabes!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
                ),
                const SizedBox(height: 32),
                AnimatedButton(
                  text: '¡Comenzar!',
                  onPressed: () {
                    setState(() {
                      _modoJuego = ModoJuego.normal;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgresoGlobal() {
    return Column(
      children: [
        const Text('Progreso General', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _ejerciciosActuales.map((ejercicio) {
            Color color = Colors.grey.shade300;
            IconData? icon;

            if (ejercicio.fueCorrecto != null) {
              color = ejercicio.fueCorrecto! ? colorCorrecto : colorIncorrecto;
              icon = ejercicio.fueCorrecto! ? Icons.check : Icons.close;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
              ),
              child: icon != null ? Icon(icon, color: Colors.white, size: 16) : null,
            );
          }).toList(),
        ),
      ]
    );
  }
  
  Widget _buildOpcionMultipleWidget(Ejercicio ejercicio) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(ejercicio.pregunta, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 25),
          ...ejercicio.opciones.map((opcion) {
            bool isSelected = _opcionSeleccionada == opcion;
            Color? borderColor;
            Color? tileColor = Colors.white;

            if (_respuestaEnviada) {
              bool esLaCorrecta = opcion == ejercicio.respuestaCorrecta;
              if (esLaCorrecta) {
                borderColor = colorCorrecto;
                if (_respuestaMostrada || isSelected) {
                  tileColor = colorCorrecto.withOpacity(0.2);
                }
              } else if (isSelected && !_respuestaMostrada) {
                borderColor = colorIncorrecto;
                tileColor = colorIncorrecto.withOpacity(0.2);
              }
            } else if (isSelected) {
              tileColor = colorPrincipal.withOpacity(0.2);
            }
            
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(opcion, style: const TextStyle(fontWeight: FontWeight.w500)),
                onTap: _respuestaEnviada ? null : () => setState(() => _opcionSeleccionada = opcion),
                tileColor: tileColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: borderColor ?? Colors.transparent, width: 2.5),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}