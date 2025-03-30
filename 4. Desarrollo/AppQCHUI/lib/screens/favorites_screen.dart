import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:AppQCHUI/models/palabra_model.dart';
import 'package:AppQCHUI/services/firestore_service.dart';

class FavoritesScreen extends StatelessWidget {
  final Set<String> favoritos;
  final Function(String) onRemoveFavorite;

  const FavoritesScreen({
    super.key,
    required this.favoritos,
    required this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Favoritos")),
      body: user == null
          ? const Center(child: Text('Inicia sesión para ver tus favoritos'))
          : StreamBuilder<List<Palabra>>(
              stream: firestoreService.getPalabrasFavoritas(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final palabras = snapshot.data ?? [];
                return palabras.isEmpty
                    ? const Center(child: Text('No tienes favoritos aún'))
                    : ListView.builder(
                        itemCount: palabras.length,
                        itemBuilder: (context, index) {
                          final palabra = palabras[index];
                          final esFavorito = favoritos.contains(palabra.id);

                          return ListTile(
                            title: Text(palabra.palabraQuechua),
                            subtitle: Text(palabra.palabraEspanol),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: esFavorito ? Colors.red : Colors.grey,
                              ),
                              onPressed: () => onRemoveFavorite(palabra.id),
                            ),
                          );
                        },
                      );
              },
            ),
    );
  }
}
