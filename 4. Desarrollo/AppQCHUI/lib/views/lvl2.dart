import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qchui/screens/activities_screen.dart'; // Asegúrate que la ruta sea correcta
import '../widgets/animated_button.dart'; // Asegúrate que la ruta sea correcta

// ==========================================================
// PARTE 1: MODELOS Y ENUMS (ACTUALIZADOS)
// ==========================================================
enum TipoEjercicio { opcionMultiple, relacionar, verdaderoFalso }

class Ejercicio {
  final String id;
  final TipoEjercicio tipo;
  final String pregunta;
  final List<String> opciones;
  final String respuestaCorrecta;
  final Map<String, String>? pares;
  bool? fueCorrecto;

  Ejercicio({
    required this.id,
    required this.tipo,
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrecta,
    this.pares,
    this.fueCorrecto,
  });

  // Constructor para crear un Ejercicio desde los datos de Firebase
  factory Ejercicio.fromMap(Map<String, dynamic> map) {
    TipoEjercicio tipo;
    switch (map['tipo']) {
      case 'relacionar':
        tipo = TipoEjercicio.relacionar;
        break;
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
      pares: map['pares'] != null ? Map<String, String>.from(map['pares']) : null,
    );
  }
}

enum ModoJuego { normal, repaso }

// ==========================================================
// PARTE 2: WIDGET PRINCIPAL (StatefulWidget)
// ==========================================================
class Level2Screen extends StatefulWidget {
  const Level2Screen({Key? key}) : super(key: key);

  @override
  _Level2ScreenState createState() => _Level2ScreenState();
}

class _Level2ScreenState extends State<Level2Screen> {
  // --- Colores y Estilos ---
  static const Color colorPrincipal = Color(0xFFE04846);
  static const Color colorFondo = Color(0xFFFFF7F7);
  static const Color colorCorrecto = Colors.green;
  static const Color colorIncorrecto = Colors.red;

  // --- NUEVO ESTADO CONECTADO A FIREBASE ---
  List<Ejercicio> _ejerciciosActuales = [];
  List<bool> _completedExercises = [];
  bool _isLoading = true;
  String? _errorMessage;
  double _currentProgress = 0.0;
  
  // --- Estado del Juego ---
  List<Ejercicio> _ejerciciosFallados = [];
  ModoJuego _modoJuego = ModoJuego.normal;
  int _currentIndex = 0;
  bool _respuestaEnviada = false;
  bool _respuestaMostrada = false;
  Map<String, String?> _seleccionesUsuarioRelacionar = {};
  String? _quechuaSeleccionado;
  String? _opcionSeleccionada;

  @override
  void initState() {
    super.initState();
    _loadExercises(); // <-- CAMBIO CLAVE: Se carga desde Firebase al iniciar.
  }

  // ==========================================================
  // PARTE 3: LÓGICA DE FIREBASE Y PROGRESO
  // ==========================================================

  Future<void> _loadExercises() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('ejercicios')
          .doc('nivel_2') // <-- ¡CLAVE! Apunta al documento del Nivel 2.
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
      setState(() => _isLoading = false);
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
              _ejerciciosActuales[i].fueCorrecto = true; // Sincroniza el estado visual
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
    
    setState(() => _currentProgress = newProgress);

    Provider.of<LevelProgress>(context, listen: false)
        .updateProgress(1, newProgress); // El índice 1 corresponde al Nivel 2.
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
      setState(() => _completedExercises[exerciseIndex] = false); // Revertir en caso de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando progreso: ${e.toString()}')),
        );
      }
    }
  }
  
  // ==========================================================
  // PARTE 4: LÓGICA DEL JUEGO
  // ==========================================================
  
  void _revisarRespuesta() {
    setState(() {
      final ejercicioActual = _ejerciciosActuales[_currentIndex];
      bool fueCorrecto = false;
      
      if(ejercicioActual.tipo == TipoEjercicio.relacionar) {
        int correctos = 0;
        ejercicioActual.pares!.forEach((key, value) {
            if (_seleccionesUsuarioRelacionar[key] == value) correctos++;
        });
        fueCorrecto = correctos == ejercicioActual.pares!.length;
      } else {
        fueCorrecto = _opcionSeleccionada == ejercicioActual.respuestaCorrecta;
      }

      ejercicioActual.fueCorrecto = fueCorrecto;

      if (fueCorrecto) {
        _completeExercise(_currentIndex); // <-- ¡INTEGRACIÓN CON FIREBASE!
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
      
      if (ejercicioActual.tipo == TipoEjercicio.relacionar) {
        _seleccionesUsuarioRelacionar = Map.from(ejercicioActual.pares!);
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
    _quechuaSeleccionado = null;
    if (_ejerciciosActuales.isNotEmpty && _ejerciciosActuales[_currentIndex].tipo == TipoEjercicio.relacionar) {
        final ejercicio = _ejerciciosActuales[_currentIndex];
        _seleccionesUsuarioRelacionar = { for (var v in ejercicio.pares!.keys) v: null };
    }
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

  void _mostrarDialogoFinal() {
    bool hayFallos = _ejerciciosFallados.isNotEmpty;
    int puntuacionFinal = _ejerciciosActuales.where((e) => e.fueCorrecto == true).length;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorFondo,
        title: Text(hayFallos && _modoJuego == ModoJuego.normal ? '¡Casi lo tienes!' : '¡Nivel Completado!', style: TextStyle(color: colorPrincipal, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tu puntuación final es: $puntuacionFinal de ${_ejerciciosActuales.length}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            if (hayFallos && _modoJuego == ModoJuego.normal) 
              Text('Tienes ${_ejerciciosFallados.length} preguntas por repasar. ¿Quieres intentarlas de nuevo?'),
            if (!hayFallos)
              Text('¡Felicidades, has dominado todos los verbos!', style: TextStyle(color: colorCorrecto)),
          ],
        ),
        actions: [
          if (hayFallos && _modoJuego == ModoJuego.normal)
            TextButton(
              onPressed: _iniciarModoRepaso,
              child: Text('Repasar Fallos', style: TextStyle(color: colorPrincipal)),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(_modoJuego == ModoJuego.normal && hayFallos ? 'Salir' : 'Finalizar', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PARTE 5: WIDGETS DE LA INTERFAZ
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: colorFondo, body: Center(child: CircularProgressIndicator(color: colorPrincipal)));
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorFondo,
        appBar: AppBar(title: Text('Error', style: TextStyle(color: Colors.white)), backgroundColor: colorPrincipal),
        body: Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!)))
      );
    }
    
    if (_ejerciciosActuales.isEmpty) {
        return Scaffold(
          backgroundColor: colorFondo,
          appBar: AppBar(title: Text('Nivel 2', style: TextStyle(color: Colors.white)), backgroundColor: colorPrincipal),
          body: Center(child: Text('No hay ejercicios disponibles para este nivel.'))
        );
    }

    final ejercicioActual = _ejerciciosActuales[_currentIndex];

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: Text(_modoJuego == ModoJuego.normal ? 'Nivel 2: Verbos' : 'Repasando Fallos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: colorPrincipal,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProgresoGlobal(),
            SizedBox(height: 16),
            Text('Pregunta ${_currentIndex + 1} de ${_ejerciciosActuales.length}', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8),
            LinearProgressIndicator(value: (_currentIndex + 1) / _ejerciciosActuales.length, backgroundColor: colorPrincipal.withOpacity(0.2), valueColor: AlwaysStoppedAnimation<Color>(colorPrincipal)),
            SizedBox(height: 20),
            
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentIndex),
                  child: ejercicioActual.tipo == TipoEjercicio.relacionar 
                      ? _buildRelacionarWidget(ejercicioActual) 
                      : _buildOpcionMultipleWidget(ejercicioActual),
                ),
              ),
            ),
            
            SizedBox(height: 10),

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
                  : ((_opcionSeleccionada != null || ejercicioActual.tipo == TipoEjercicio.relacionar) ? _revisarRespuesta : null),
              enabled: _respuestaEnviada || 
                       (ejercicioActual.tipo == TipoEjercicio.relacionar 
                          ? _seleccionesUsuarioRelacionar.values.every((v) => v != null) 
                          : _opcionSeleccionada != null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgresoGlobal() {
    return Column(
      children: [
        Text('Progreso General', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        SizedBox(height: 8),
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
              margin: EdgeInsets.symmetric(horizontal: 2),
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
    // ... (Este widget no necesita cambios, se mantiene igual)
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(ejercicio.pregunta, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 25),
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
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(opcion, style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: _respuestaEnviada ? null : () => setState(() => _opcionSeleccionada = opcion),
                tileColor: tileColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: borderColor ?? Colors.transparent, width: 2.5),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildRelacionarWidget(Ejercicio ejercicio) {
    // ... (Este widget no necesita cambios, se mantiene igual)
    void seleccionarQuechua(String quechua) => setState(() => _quechuaSeleccionado = quechua);
    void seleccionarEspanol(String espanol) {
      if (_quechuaSeleccionado != null) {
        setState(() {
          _seleccionesUsuarioRelacionar.removeWhere((key, value) => value == espanol);
          _seleccionesUsuarioRelacionar[_quechuaSeleccionado!] = espanol;
          _quechuaSeleccionado = null;
        });
      }
    }

    return Column(
      children: [
        Text(ejercicio.pregunta, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 20),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ejercicio.pares!.keys.map((quechua) {
                  bool estaEmparejado = _seleccionesUsuarioRelacionar[quechua] != null;
                  Color borderColor = Colors.grey.shade400;
                  if (_respuestaEnviada) {
                    bool esCorrecto = _seleccionesUsuarioRelacionar[quechua] == ejercicio.pares![quechua];
                    borderColor = esCorrecto ? colorCorrecto : colorIncorrecto;
                  } else if (_quechuaSeleccionado == quechua) {
                    borderColor = colorPrincipal;
                  }
                  return OutlinedButton(
                    onPressed: _respuestaEnviada ? null : () => seleccionarQuechua(quechua),
                    child: Text(quechua, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: estaEmparejado ? colorPrincipal.withOpacity(0.1) : Colors.white,
                      side: BorderSide(color: borderColor, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  );
                }).toList(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ejercicio.opciones.map((espanol) {
                  String? quechuaEmparejado;
                  _seleccionesUsuarioRelacionar.forEach((key, value) { if (value == espanol) quechuaEmparejado = key; });
                  
                  Color bgColor = Colors.white;
                  Color borderColor = Colors.grey.shade400;

                  if (_respuestaEnviada && quechuaEmparejado != null) {
                    bool esCorrecto = ejercicio.pares![quechuaEmparejado] == espanol;
                    borderColor = esCorrecto ? colorCorrecto : colorIncorrecto;
                    bgColor = esCorrecto ? colorCorrecto.withOpacity(0.1) : colorIncorrecto.withOpacity(0.1);
                  }

                  return InkWell(
                    onTap: _respuestaEnviada ? null : () => seleccionarEspanol(espanol),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: 2)
                      ),
                      child: Text(espanol, style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}