import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        // Verificar si el usuario ya tiene datos en Firestore
        DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(user.uid).get();

        if (!userDoc.exists) {
          await _firestore.collection('usuarios').doc(user.uid).set({
            'nombre': email.split('@')[0], // Nombre provisional basado en el email
            'email': email,
            'fechaRegistro': FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } catch (e) {
      print("Error al iniciar sesión: $e");
      return null;
    }
  }

  Future<User?> registerWithEmail(String email, String password, String nombre) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        await _firestore.collection('usuarios').doc(user.uid).set({
          'nombre': nombre.trim(), // Nombre completo proporcionado
          'email': email,
          'fechaRegistro': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print("Error al registrarse: $e");
      return null;
    }
  }

  Future<void> updateUserName(String uid, String newName) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'nombre': newName.trim(),
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error al actualizar nombre: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}