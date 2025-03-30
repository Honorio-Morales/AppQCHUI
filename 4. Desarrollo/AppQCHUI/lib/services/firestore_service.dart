import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/palabra_model.dart';
import '../models/favorito_model.dart';
import '../models/pregunta_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Diccionario
  Stream<List<Palabra>> getPalabras() {
    return _firestore.collection('diccionario').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Palabra.fromFirestore(doc)).toList();
    });
  }

  Future<List<Palabra>> buscarPalabras(String query) async {
    final snapshot = await _firestore
        .collection('diccionario')
        .where('quechua', isGreaterThanOrEqualTo: query)
        .where('quechua', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs.map((doc) => Palabra.fromFirestore(doc)).toList();
  }

  // Favoritos
  Future<void> addFavorito(Favorito favorito) {
    return _firestore.collection('favoritos').add(favorito.toMap());
  }

  Future<void> removeFavorito(String favoritoId) {
    return _firestore.collection('favoritos').doc(favoritoId).delete();
  }

  Stream<List<Favorito>> getFavoritos(String usuarioUid) {
    return _firestore
        .collection('favoritos')
        .where('usuario_uid', isEqualTo: usuarioUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Favorito.fromFirestore(doc)).toList();
    });
  }

  // Comunidad
  Stream<List<Pregunta>> getPreguntas() {
    return _firestore
        .collection('comunidad')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Pregunta.fromFirestore(doc)).toList();
    });
  }

  Future<void> addPregunta(Pregunta pregunta) async {
    print("Guardando pregunta con datos:");
    print("Usuario UID: ${pregunta.usuarioUid}");
    print("Nombre Usuario: ${pregunta.nombreUsuario}");
    print("Texto: ${pregunta.texto}");

    await _firestore.collection('comunidad').add({
      'usuario_uid': pregunta.usuarioUid,
      'nombreUsuario': pregunta.nombreUsuario, // Asegura que se guarde correctamente
      'texto': pregunta.texto,
      'fecha': Timestamp.fromDate(pregunta.fecha),
    });
  }

  Stream<bool> esFavorito(String usuarioUid, String palabraId) {
    return _firestore
        .collection('favoritos')
        .where('usuario_uid', isEqualTo: usuarioUid)
        .where('palabra_id', isEqualTo: palabraId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  // Método para toggle (añadir/eliminar) favoritos con transacción
  Future<void> toggleFavorito(String usuarioUid, String palabraId) async {
    final favoritoRef = _firestore.collection('favoritos');

    await _firestore.runTransaction((transaction) async {
      final query = await favoritoRef
          .where('usuario_uid', isEqualTo: usuarioUid)
          .where('palabra_id', isEqualTo: palabraId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        transaction.set(favoritoRef.doc(), {
          'usuario_uid': usuarioUid,
          'palabra_id': palabraId,
          'fecha': Timestamp.now(),
        });
      } else {
        transaction.delete(query.docs.first.reference);
      }
    });
  }

  // Obtener palabras favoritas con datos completos (optimizando con Future.wait)
  Stream<List<Palabra>> getPalabrasFavoritas(String usuarioUid) {
    return _firestore
        .collection('favoritos')
        .where('usuario_uid', isEqualTo: usuarioUid)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Future<Palabra?>> futuros = snapshot.docs.map((doc) async {
        final palabraDoc =
            await _firestore.collection('diccionario').doc(doc['palabra_id']).get();
        return palabraDoc.exists ? Palabra.fromFirestore(palabraDoc) : null;
      }).toList();

      final palabras = await Future.wait(futuros);
      return palabras.where((palabra) => palabra != null).cast<Palabra>().toList();
    });
  }
}
