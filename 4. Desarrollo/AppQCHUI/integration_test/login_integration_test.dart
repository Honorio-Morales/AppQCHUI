// integration_test/login_integration_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qchui/main.dart' as app; // Importa el punto de entrada principal de tu aplicación
import 'package:firebase_auth/firebase_auth.dart'; // Para interactuar con Firebase Authentication
import 'package:firebase_core/firebase_core.dart'; // Necesario para Firebase.initializeApp()

// Función principal donde se definen y ejecutan las pruebas de integración.
void main() {
  // Paso 1 (Global): Asegurar que el binding de Flutter para pruebas de widgets esté inicializado.
  // Esto es CRUCIAL para que las pruebas de integración que interactúan con la UI funcionen.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // --- CONFIGURACIÓN DE CREDENCIALES DE PRUEBA ---
  // Define aquí las credenciales que usarás en tus pruebas.
  // !!! IMPORTANTE: Estas deben ser credenciales de un usuario de PRUEBA VÁLIDO en tu proyecto Firebase. !!!
  const String validTestEmail = 'appqchui@gmail.com'; // Email de un usuario existente y válido.
  const String validTestPassword = 'appqchui';       // Contraseña para ese usuario.
  const String invalidTestEmail = 'invalid@test.com';    // Email que sabes que no existe o es inválido.
  const String invalidTestPassword = 'wrongpassword';  // Contraseña incorrecta.
  // --- FIN DE CONFIGURACIÓN DE CREDENCIALES ---

  // Paso 2 (Global): Configuración que se ejecuta UNA SOLA VEZ antes de TODAS las pruebas en este archivo.
  setUpAll(() async {
    // Es VITAL inicializar Firebase aquí para el entorno de prueba.
    // Sin esto, cualquier intento de usar Firebase (ej. FirebaseAuth.instance) fallará.
    await Firebase.initializeApp();
    print("INFO: Firebase inicializado para las pruebas de integración.");
  });

  // Define un grupo de pruebas relacionadas con el flujo de inicio de sesión.
  // Agrupar pruebas ayuda a organizarlas y a aplicar configuraciones comunes (setUp/tearDown).
  group('Pruebas de Flujo de Inicio de Sesión', () {
    // Configuración que se ejecuta ANTES de CADA prueba individual dentro de este grupo.
    setUp(() async {
      // Asegurar un estado limpio antes de cada prueba: si hay un usuario logueado, se desconecta.
      // Esto evita que el estado de una prueba afecte a la siguiente.
      if (FirebaseAuth.instance.currentUser != null) {
        final userEmail = FirebaseAuth.instance.currentUser!.email; // Obtener email para el log.
        await FirebaseAuth.instance.signOut();
        print("INFO: Usuario ($userEmail) desconectado en setUp.");
      }
      // Pequeña pausa para asegurar que los streams de autenticación y la UI tengan tiempo de actualizarse.
      // A veces, pumpAndSettle después de app.main() es suficiente, pero esto puede ayudar a estabilizar.
      await Future.delayed(const Duration(milliseconds: 100));
    });

    // Prueba 1: Verificar que la app inicia, muestra HomeScreen y se puede navegar a LoginScreen.
    testWidgets('La app inicia, muestra HomeScreen y navega a LoginScreen',
        (WidgetTester tester) async {
      print("EJECUTANDO PRUEBA: La app inicia, muestra HomeScreen y navega a LoginScreen");

      // 1. Arrancar la aplicación llamando a su función main.
      app.main();
      // Esperar a que la UI se construya, las animaciones terminen y la app se estabilice.
      // La duración puede necesitar ajuste dependiendo de la complejidad de tu app.
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 2. Verificar que estamos en HomeScreen (cuando no hay usuario logueado).
      //    HomeScreen debería mostrar el título 'Aprende Quechua'.
      expect(find.text('Aprende Quechua'), findsOneWidget, reason: "FALLÓ: No se encontró el título 'Aprende Quechua' en HomeScreen.");
      //    Y debería haber un botón para 'Iniciar Sesión' en la AppBar (identificado por su tooltip).
      final appBarLoginButton = find.byTooltip('Iniciar Sesión');
      expect(appBarLoginButton, findsOneWidget, reason: "FALLÓ: No se encontró el botón de Iniciar Sesión (tooltip) en la AppBar de HomeScreen.");

      // 3. Simular un tap en el botón de login de la AppBar para ir a LoginScreen.
      await tester.tap(appBarLoginButton);
      await tester.pumpAndSettle(const Duration(seconds: 1)); // Esperar la navegación.

      // 4. Verificar que hemos llegado a LoginScreen.
      //    LoginScreen debería tener un AppBar con el título 'Iniciar Sesión'.
      expect(find.text('Iniciar Sesión'), findsOneWidget, reason: "FALLÓ: No se encontró el título 'Iniciar Sesión' en la AppBar de LoginScreen.");
      //    Debería tener campos para 'Correo electrónico' y 'Contraseña'.
      expect(find.widgetWithText(TextFormField, 'Correo electrónico'), findsOneWidget, reason: "FALLÓ: No se encontró el campo 'Correo electrónico' en LoginScreen.");
      expect(find.widgetWithText(TextFormField, 'Contraseña'), findsOneWidget, reason: "FALLÓ: No se encontró el campo 'Contraseña' en LoginScreen.");
      //    Y un botón con el texto 'INICIAR SESIÓN'.
      expect(find.widgetWithText(ElevatedButton, 'INICIAR SESIÓN'), findsOneWidget, reason: "FALLÓ: No se encontró el botón 'INICIAR SESIÓN' en LoginScreen.");
      
      print("PRUEBA COMPLETADA: La app inicia, muestra HomeScreen y navega a LoginScreen");
    });

    // Prueba 2: Verificar que intentar loguearse con credenciales incorrectas muestra un mensaje de error.
    testWidgets('Login con credenciales inválidas muestra mensaje de error',
        (WidgetTester tester) async {
      print("EJECUTANDO PRUEBA: Login con credenciales inválidas muestra mensaje de error");
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Navegar a LoginScreen.
      final appBarLoginButton = find.byTooltip('Iniciar Sesión');
      expect(appBarLoginButton, findsOneWidget, reason: "FALLÓ: (Error previo a la prueba) No se encontró el botón de Iniciar Sesión (tooltip) para navegar a LoginScreen.");
      await tester.tap(appBarLoginButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Encontrar los campos y el botón en LoginScreen.
      final emailField = find.widgetWithText(TextFormField, 'Correo electrónico');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      final loginButton = find.widgetWithText(ElevatedButton, 'INICIAR SESIÓN');

      expect(emailField, findsOneWidget, reason: "FALLÓ: No se encontró el campo 'Correo electrónico' en LoginScreen.");
      expect(passwordField, findsOneWidget, reason: "FALLÓ: No se encontró el campo 'Contraseña' en LoginScreen.");
      expect(loginButton, findsOneWidget, reason: "FALLÓ: No se encontró el botón 'INICIAR SESIÓN' en LoginScreen.");

      // Ingresar credenciales incorrectas.
      await tester.enterText(emailField, invalidTestEmail);
      await tester.enterText(passwordField, invalidTestPassword);
      await tester.pump(); // Para que los controladores de texto se actualicen.

      // Tocar el botón de login.
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Esperar a que se procese el login y aparezca el error.

      // Verificar que se muestra un mensaje de error.
      // Buscamos un widget Text que contenga alguna de las frases de error comunes.
      // Esto es más flexible que buscar un texto exacto, ya que los mensajes de error pueden variar.
      expect(
          find.byWidgetPredicate((widget) { // Busca un widget que cumpla una condición personalizada.
            if (widget is Text && widget.data != null) { // Si el widget es un Text y tiene datos...
              final text = widget.data!.toLowerCase(); // Convertir a minúsculas para comparación insensible.
              // Comprobar si el texto contiene alguna de las cadenas de error esperadas.
              return text.contains('usuario no encontrado') ||
                     text.contains('contraseña incorrecta') ||
                     text.contains('error al iniciar sesión') ||
                     text.contains('invalid-credential') || // Código de error común de Firebase Auth.
                     text.contains('credenciales no válidas');
            }
            return false; // Si no es un Text o no cumple las condiciones, no es el widget buscado.
          }),
          findsOneWidget, reason: "FALLÓ: No se mostró el mensaje de error esperado para credenciales inválidas, o el texto no coincide con las frases esperadas.");

      // Verificar que seguimos en la pantalla de Login (el botón de login aún debe estar visible).
      expect(loginButton, findsOneWidget, reason: "FALLÓ: El botón 'INICIAR SESIÓN' debería seguir visible después de un intento de login fallido.");
      print("PRUEBA COMPLETADA: Login con credenciales inválidas muestra mensaje de error");
    });

    // Prueba 3: Verificar que loguearse con credenciales válidas navega a la pantalla principal (MainNavigationWrapper).
    testWidgets('Login con credenciales válidas navega a MainNavigationWrapper',
        (WidgetTester tester) async {
      print("EJECUTANDO PRUEBA: Login con credenciales válidas navega a MainNavigationWrapper");
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Navegar a LoginScreen.
      final appBarLoginButton = find.byTooltip('Iniciar Sesión');
      expect(appBarLoginButton, findsOneWidget, reason: "FALLÓ: (Error previo a la prueba) No se encontró el botón de Iniciar Sesión (tooltip) para navegar a LoginScreen.");
      await tester.tap(appBarLoginButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Encontrar campos y botón.
      final emailField = find.widgetWithText(TextFormField, 'Correo electrónico');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      final loginButton = find.widgetWithText(ElevatedButton, 'INICIAR SESIÓN');

      // Ingresar credenciales válidas.
      await tester.enterText(emailField, validTestEmail);
      await tester.enterText(passwordField, validTestPassword);
      await tester.pump();

      // Tocar el botón de login.
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Dar tiempo para Firebase Auth y navegación.

      // Verificar que ya NO estamos en LoginScreen.
      expect(find.widgetWithText(ElevatedButton, 'INICIAR SESIÓN'), findsNothing, reason: "FALLÓ: El botón 'INICIAR SESIÓN' (de LoginScreen) no debería estar visible después de un login exitoso.");
      
      // Verificar que hemos navegado a MainNavigationWrapper (que tiene un BottomNavigationBar).
      expect(find.byType(BottomNavigationBar), findsOneWidget, reason: "FALLÓ: No se encontró el BottomNavigationBar. ¿Se navegó correctamente a MainNavigationWrapper?");

      // Verificar el mensaje de bienvenida personalizado en HomeScreen.
      final welcomeMessagePrefix = validTestEmail.split('@')[0]; // Obtener la parte del email antes del @.
      expect(find.textContaining('¡Bienvenido, $welcomeMessagePrefix'), findsOneWidget, reason: "FALLÓ: No se encontró el mensaje de bienvenida para el usuario '$welcomeMessagePrefix' o el texto no coincide.");
      
      // --- CORRECCIÓN PARA ENCONTRAR EL BOTÓN DE DICCIONARIO ---
      // Verificar que el botón de diccionario existe en HomeScreen cuando el usuario está logueado.
      // 1. Encontrar el TEXTO del botón, ya que es distintivo.
      final dictionaryButtonTextFinder = find.text('DICCIONARIO QUECHUA-ESPAÑOL');
      expect(
        dictionaryButtonTextFinder,
        findsOneWidget,
        reason: "FALLÓ: No se encontró el TEXTO 'DICCIONARIO QUECHUA-ESPAÑOL'. Verifica que el texto sea exacto en HomeScreen.dart cuando el usuario está logueado."
      );

      // 2. Verificar que este texto es parte de un ElevatedButton.
      // Esto asegura que no solo el texto está presente, sino que es parte del tipo de botón esperado.
      expect(
        find.ancestor( // Busca un widget "padre" o "abuelo" (ancestro).
          of: dictionaryButtonTextFinder, // Del texto que acabamos de encontrar.
          matching: find.byType(ElevatedButton) // Ese ancestro debe ser un ElevatedButton.
        ),
        findsOneWidget, // Esperamos encontrar uno de estos ancestros que sea ElevatedButton.
        reason: "FALLÓ: El texto 'DICCIONARIO QUECHUA-ESPAÑOL' se encontró, pero no parece ser parte de un ElevatedButton. Revisa la estructura del widget en HomeScreen.dart (¿es un ElevatedButton.icon o similar?)."
      );
      // --- FIN DE LA CORRECCIÓN ---
      
      print("PRUEBA COMPLETADA: Login con credenciales válidas navega a MainNavigationWrapper");
    });

    // Prueba 4: Verificar que si un usuario ya está logueado, la app redirige directamente a /main.
    testWidgets('Redirige a /main si el usuario ya está logueado',
        (WidgetTester tester) async {
      print("EJECUTANDO PRUEBA: Redirige a /main si el usuario ya está logueado");
      
      // 1. Loguear un usuario programáticamente ANTES de iniciar la app para la prueba.
      //    Esto simula un usuario que ya tenía una sesión activa.
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: validTestEmail,
          password: validTestPassword,
        );
        // Verificar que el login programático fue exitoso.
        expect(userCredential.user, isNotNull, reason: "FALLÓ: (Setup de prueba) Firebase Auth no devolvió un usuario después del inicio de sesión programático.");
        print("INFO: Usuario de prueba ($validTestEmail) logueado programáticamente para la prueba de redirección.");
      } catch (e) {
        // Si el login falla aquí, la prueba no puede continuar. Es un error en la configuración de la prueba o las credenciales.
        fail('FALLO CRÍTICO DE PRUEBA: No se pudo iniciar sesión con el usuario de prueba "$validTestEmail" ANTES de app.main(): $e. Asegúrate de que el usuario y la contraseña sean correctos en Firebase.');
      }
      // Doble verificación de que el usuario actual no es nulo.
      expect(FirebaseAuth.instance.currentUser, isNotNull, reason: "FALLÓ: (Setup de prueba) El usuario de prueba no pudo iniciar sesión programáticamente (currentUser es null).");

      // 2. Arrancar la aplicación.
      app.main();
      // AuthWrapper (o tu lógica de redirección) debería detectar al usuario logueado y redirigir.
      // pumpAndSettle esperará a que esta navegación se complete.
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 3. Verificar que NO estamos en LoginScreen ni en la HomeScreen inicial (sin login).
      //    El botón de LoginScreen no debería estar.
      expect(find.widgetWithText(ElevatedButton, 'INICIAR SESIÓN'), findsNothing, reason: "FALLÓ: Se encontró el botón de LoginScreen; la redirección automática a /main parece haber fallado.");
      //    El botón de login de la AppBar de HomeScreen (para usuarios no logueados) tampoco debería estar.
      expect(find.byTooltip('Iniciar Sesión'), findsNothing, reason: "FALLÓ: Se encontró el botón de Iniciar Sesión (tooltip) de HomeScreen (estado no logueado); la redirección automática falló.");

      // 4. Verificar que estamos en MainNavigationWrapper (o la pantalla principal después del login).
      expect(find.byType(BottomNavigationBar), findsOneWidget, reason: "FALLÓ: No se encontró el BottomNavigationBar después de la redirección automática. ¿Estamos en la pantalla correcta?");
      final welcomeMessagePrefix = validTestEmail.split('@')[0];
      expect(find.textContaining('¡Bienvenido, $welcomeMessagePrefix'), findsOneWidget, reason: "FALLÓ: No se encontró el mensaje de bienvenida después de la redirección automática.");
      
      print("PRUEBA COMPLETADA: Redirige a /main si el usuario ya está logueado");
    });
  }); // Fin del group 'Pruebas de Flujo de Inicio de Sesión'

  // Paso 3 (Global): Limpieza que se ejecuta UNA SOLA VEZ después de TODAS las pruebas en este archivo.
  tearDownAll(() async {
    // Buena práctica: asegurar que el último usuario de prueba se desconecte.
    if (FirebaseAuth.instance.currentUser != null) {
      final userEmail = FirebaseAuth.instance.currentUser!.email;
      await FirebaseAuth.instance.signOut();
      print("INFO: Desconexión final completada en tearDownAll para el usuario: $userEmail.");
    } else {
      print("INFO: tearDownAll ejecutado, no había usuario para desconectar.");
    }
  });
}