import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/animated_button.dart'; // Asegúrate de que la ruta a tu botón sea correcta

// ==========================================================
// PARTE 1: MODELOS Y ENUMS
// ==========================================================
class VerbPair {
  final String quechua;
  final String espanol;
  VerbPair(this.quechua, this.espanol);
}

enum TipoEjercicio { opcionMultiple, relacionar, verdaderoFalso }

class Ejercicio {
  final TipoEjercicio tipo;
  final String pregunta;
  final List<String> opciones;
  final String respuestaCorrecta;
  final Map<String, String>? pares;
  
  bool? fueCorrecto; 

  Ejercicio({
    required this.tipo,
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrecta,
    this.pares,
    this.fueCorrecto,
  });
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

  // --- Lista de Datos ---
  final List<VerbPair> _verbos = [
    VerbPair('Kay', 'Ser, existir'), VerbPair('Pukllay', 'Jugar'), VerbPair('Tusuy', 'Bailar'),
    VerbPair('Uyariy', 'Escuchar'), VerbPair('Rimay', 'Hablar'), VerbPair('Wayk\'uy', 'Cocinar'),
    VerbPair('Yuyariy', 'Recordar'), VerbPair('Yuyay', 'Pensar'), VerbPair('Punay', 'Dormir'),
    VerbPair('Mikhuy', 'Comer'), VerbPair('Takiy', 'Cantar'), VerbPair('Maqlliy', 'Lavar'),
    VerbPair('Ruway', 'Hacer'), VerbPair('Asiy', 'Reír'), VerbPair('Kaway', 'Mirar'),
    VerbPair('Puryi', 'Caminar'), VerbPair('Jalay', 'Volar'), VerbPair('Munay', 'Amar'),
    VerbPair('Willay', 'Decir, avisar'), VerbPair('Paway', 'Correr'),
  ];

  // --- Estado del Widget ---
  late List<Ejercicio> _todosLosEjercicios;
  late List<Ejercicio> _ejerciciosActuales;
  List<Ejercicio> _ejerciciosFallados = [];
  
  ModoJuego _modoJuego = ModoJuego.normal;
  int _currentIndex = 0;
  bool _respuestaEnviada = false;
  bool _respuestaMostrada = false; // NUEVO: Para saber si el usuario pidió la respuesta.
  
  Map<String, String?> _seleccionesUsuarioRelacionar = {};
  String? _quechuaSeleccionado;
  String? _opcionSeleccionada;

  @override
  void initState() {
    super.initState();
    _iniciarNivel();
  }

  // ==========================================================
  // PARTE 3: LÓGICA DEL JUEGO
  // ==========================================================

  void _iniciarNivel() {
    _verbos.shuffle();
    _todosLosEjercicios = _generarEjercicios(6);
    _ejerciciosActuales = List.from(_todosLosEjercicios);
    _ejerciciosFallados = [];
    _modoJuego = ModoJuego.normal;
    _currentIndex = 0;
    _reiniciarEstadoPregunta();
    setState(() {});
  }
  
  List<Ejercicio> _generarEjercicios(int cantidad) {
      final List<Ejercicio> generados = [];
      int verbosIndex = 0;
      final tipos = [0,1,2,0,1,2]..shuffle();

      for (var tipoId in tipos) {
          if (verbosIndex >= _verbos.length) break;
          
          if(tipoId == 1 && verbosIndex + 4 <= _verbos.length) {
              generados.add(_crearEjercicioRelacionar(_verbos.sublist(verbosIndex, verbosIndex+4)));
              verbosIndex += 4;
          } else if(tipoId != 1) {
              if (tipoId == 0) generados.add(_crearEjercicioOpcionMultiple(_verbos[verbosIndex]));
              else generados.add(_crearEjercicioVerdaderoFalso(_verbos[verbosIndex]));
              verbosIndex++;
          }
      }
      return generados.take(cantidad).toList();
  }

  Ejercicio _crearEjercicioOpcionMultiple(VerbPair verboCorrecto) {
    List<String> opciones = _getOpcionesIncorrectas(verboCorrecto.espanol, 3)..add(verboCorrecto.espanol)..shuffle();
    return Ejercicio(tipo: TipoEjercicio.opcionMultiple, pregunta: '¿Qué significa "${verboCorrecto.quechua}"?', opciones: opciones, respuestaCorrecta: verboCorrecto.espanol);
  }

  Ejercicio _crearEjercicioRelacionar(List<VerbPair> verbos) {
    return Ejercicio(tipo: TipoEjercicio.relacionar, pregunta: 'Une el verbo con su significado', opciones: verbos.map((v) => v.espanol).toList()..shuffle(), respuestaCorrecta: '', pares: { for (var v in verbos) v.quechua : v.espanol });
  }

  Ejercicio _crearEjercicioVerdaderoFalso(VerbPair verboPregunta) {
    bool esAfirmacionCorrecta = Random().nextBool();
    String significadoAsignado = esAfirmacionCorrecta ? verboPregunta.espanol : _getOpcionesIncorrectas(verboPregunta.espanol, 1).first;
    return Ejercicio(tipo: TipoEjercicio.verdaderoFalso, pregunta: 'La palabra "${verboPregunta.quechua}" significa "$significadoAsignado".', opciones: ['Verdadero', 'Falso'], respuestaCorrecta: esAfirmacionCorrecta ? 'Verdadero' : 'Falso');
  }

  List<String> _getOpcionesIncorrectas(String correcta, int cantidad) {
      final opciones = <String>{};
      final copiaVerbos = List<VerbPair>.from(_verbos)..shuffle();
      for (var verbo in copiaVerbos) {
          if (verbo.espanol != correcta) opciones.add(verbo.espanol);
          if (opciones.length == cantidad) break;
      }
      return opciones.toList();
  }
  
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

      if (!fueCorrecto && _modoJuego == ModoJuego.normal) {
        _ejerciciosFallados.add(ejercicioActual);
      }
      
      _respuestaEnviada = true;
    });
  }

  // NUEVA FUNCIÓN para mostrar la respuesta
  void _mostrarRespuesta() {
    setState(() {
      final ejercicioActual = _ejerciciosActuales[_currentIndex];
      
      // La respuesta se marca como incorrecta
      ejercicioActual.fueCorrecto = false;

      // Se añade a los fallos para el modo repaso
      if (_modoJuego == ModoJuego.normal && !_ejerciciosFallados.contains(ejercicioActual)) {
        _ejerciciosFallados.add(ejercicioActual);
      }
      
      // Para el tipo 'relacionar', llenamos las selecciones con las respuestas correctas
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
    _respuestaMostrada = false; // MODIFICADO: Reiniciar el estado
    _opcionSeleccionada = null;
    _quechuaSeleccionado = null;
    if (_ejerciciosActuales[_currentIndex].tipo == TipoEjercicio.relacionar) {
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
    int puntuacionFinal = _todosLosEjercicios.where((e) => e.fueCorrecto == true).length;
    
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
            Text('Tu puntuación final es: $puntuacionFinal de ${_todosLosEjercicios.length}', style: TextStyle(fontSize: 18)),
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
              Navigator.of(context).pop(); // Vuelve a la pantalla de selección de niveles
            },
            child: Text(_modoJuego == ModoJuego.normal && hayFallos ? 'Salir' : 'Finalizar', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PARTE 4: WIDGETS DE LA INTERFAZ
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    // Estado de carga inicial
    if (_ejerciciosActuales.isEmpty) {
      return Scaffold(backgroundColor: colorFondo, body: Center(child: CircularProgressIndicator(color: colorPrincipal)));
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
                  key: ValueKey<int>(_currentIndex), // Para que AnimatedSwitcher sepa que el widget cambió
                  child: ejercicioActual.tipo == TipoEjercicio.relacionar 
                      ? _buildRelacionarWidget(ejercicioActual) 
                      : _buildOpcionMultipleWidget(ejercicioActual),
                ),
              ),
            ),
            
            SizedBox(height: 10),

            // NUEVO: Botón para mostrar la respuesta
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
                  : (_opcionSeleccionada != null || ejercicioActual.tipo == TipoEjercicio.relacionar ? _revisarRespuesta : null),
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
          children: _todosLosEjercicios.map((ejercicio) {
            Color color = Colors.grey.shade300;
            IconData? icon;

            if (ejercicio.fueCorrecto != null) {
              if (ejercicio.fueCorrecto!) {
                color = colorCorrecto;
                icon = Icons.check;
              } else {
                color = colorIncorrecto;
                icon = Icons.close;
              }
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(ejercicio.pregunta, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 25),
          ...ejercicio.opciones.map((opcion) {
            bool isSelected = _opcionSeleccionada == opcion;
            Color? borderColor;
            Color? tileColor = Colors.white;

            // MODIFICADO: Lógica de colores para incluir el estado _respuestaMostrada
            if (_respuestaEnviada) {
              bool esLaCorrecta = opcion == ejercicio.respuestaCorrecta;

              if (esLaCorrecta) {
                borderColor = colorCorrecto;
                // Si la respuesta fue mostrada o el usuario la acertó, se pinta de verde
                if (_respuestaMostrada || isSelected) {
                  tileColor = colorCorrecto.withOpacity(0.2);
                }
              } else if (isSelected && !_respuestaMostrada) {
                // Solo se pinta de rojo si el usuario seleccionó una incorrecta (y no pidió la respuesta)
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