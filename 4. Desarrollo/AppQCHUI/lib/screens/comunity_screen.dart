import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CommunityScreen extends StatelessWidget {
  CommunityScreen({super.key});

  // Simulación de publicaciones de la comunidad
  final List<Map<String, String>> posts = [
    {'user': 'Ana', 'message': 'Estoy aprendiendo quechua, ¿algún consejo?'},
    {'user': 'Carlos', 'message': 'Aquí en mi pueblo todavía hablamos quechua todos los días.'},
    {'user': 'María', 'message': 'Recomiendo usar apps de traducción y practicar con hablantes nativos.'},
    {'user': 'Luis', 'message': 'El quechua tiene muchas palabras bonitas, me encanta aprenderlo.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.green),
                title: Text(
                  posts[index]['user']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(posts[index]['message']!),
              ),
            ),
          );
        },
      ),
    );
  }
}

