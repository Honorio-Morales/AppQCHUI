import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qchui/screens/activities_screen.dart';

class Nivel4Page extends StatefulWidget {
  const Nivel4Page({super.key});

  @override
  State<Nivel4Page> createState() => _Nivel4PageState();
}

class _Nivel4PageState extends State<Nivel4Page> {
  int preguntaActual = 0;
  bool mostrarResultado = false;
  bool respuestaCorrecta = false;

  final List<Map<String, dynamic>> ejercicios = [
    {
      'oracion': 'Ñuqa ___ kani.',
      'opciones': ['runa', 'misi', 'allin', 'wasi'],
      'respuesta': 'runa',
    },
    {
      'oracion': 'Pay wasita ___.',
      'opciones': ['mikun', 'riqan', 'riman', 'manta'],
      'respuesta': 'riqan',
    },
    {
      'oracion': '___ sumaqmi.',
      'opciones': ['Wasi', 'Qocha', 'Sumaq', 'Runa'],
      'respuesta': 'Wasi',
    },
    {
      'oracion': 'Ñuqanchik ___ tiyayku.',
      'opciones': ['ayllupi', 'mikhuy', 'rikhuy', 'amachay'],
      'respuesta': 'ayllupi',
    },
    {
      'oracion': 'Qosqopi ___.',
      'opciones': ['tiyakuni', 'tarpuy', 'sumaq', 'waykuy'],
      'respuesta': 'tiyakuni',
    },
  ];

  void verificarRespuesta(String seleccion) {
    final correcta = ejercicios[preguntaActual]['respuesta'];
    setState(() {
      respuestaCorrecta = seleccion == correcta;
      mostrarResultado = true;
    });
  }

  void siguientePregunta() {
    if (preguntaActual < ejercicios.length - 1) {
      setState(() {
        preguntaActual++;
        mostrarResultado = false;
      });
    } else {
      setState(() {
        mostrarResultado = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Completaste el Nivel 4!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pregunta = ejercicios[preguntaActual];

    return Scaffold(
      appBar: AppBar(title: const Text("Nivel 4 - Completa la oración")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              pregunta['oracion'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...pregunta['opciones'].map<Widget>((opcion) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: mostrarResultado ? null : () => verificarRespuesta(opcion),
                  child: Text(opcion),
                ),
              );
            }).toList(),
            if (mostrarResultado)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    respuestaCorrecta ? Icons.check_circle : Icons.cancel,
                    color: respuestaCorrecta ? Colors.green : Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: siguientePregunta,
                    child: const Text("Siguiente"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}