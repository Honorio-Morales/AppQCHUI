import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:AppQCHUI/models/palabra_model.dart';
import 'package:AppQCHUI/services/firebase_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: StreamBuilder<Set<String>>(
        stream: _firebaseService.getFavoritos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final favoritosIds = snapshot.data!;

          return StreamBuilder<List<Palabra>>(
            stream: _firebaseService.getPalabras(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final palabras = snapshot.data!;
              final favoritos = palabras.where((p) => favoritosIds.contains(p.id)).toList();

              return ListView.builder(
                itemCount: favoritos.length,
                itemBuilder: (context, index) {
                  final palabra = favoritos[index];
                  return ListTile(
                    title: Text(palabra.palabraEspanol),
                    subtitle: Text(palabra.palabraQuechua),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}