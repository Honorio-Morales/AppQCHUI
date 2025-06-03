import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qchui/main.dart' as app; // Importa tu punto de entrada principal
import 'package:firebase_auth/firebase_auth.dart'; // Para cerrar sesión

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // --- CONFIGURACIÓN DE CREDENCIALES DE PRUEBA ---
  // !!! REEMPLAZA ESTAS CREDENCIALES CON LAS DE UN USUARIO DE PRUEBA VÁLIDO EN TU FIREBASE !!!
  const String validTestEmail = 'angiezulema@hotmail.com';
  const String validTestPassword = 'angiezulema';
  const String invalidTestEmail = 'invalid@test.com';
  const String invalidTestPassword = 'wrongpassword';
  // --- FIN DE CONFIGURACIÓN DE CREDENCIALES ---

  group('Login Flow Integration Tests', () {
    setUp(() async {
      // Asegurarse de que no haya ningún usuario logueado antes de cada prueba
      // Esto ayuda a mantener las pruebas aisladas.
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
      // Pequeña pausa para asegurar que el stream de auth se actualice
      await Future.delayed(const Duration(milliseconds: 500));
    });

    testWidgets('App starts and shows HomeScreen, then navigates to LoginScreen',
        (WidgetTester tester) async {
      // 1. Arranca la aplicación.
      app.main();
      await tester.pumpAndSettle(); // Espera a que la UI se estabilice (AuthWrapper procese)

      // 2. Verificar que estamos en HomeScreen (porque no hay usuario logueado)
      //    El título del AppBar de HomeScreen es 'Aprende Quechua'
      expect(find.text('Aprende Quechua'), findsOneWidget);
      //    Y debería haber un botón de login en la AppBar
      final appBarLoginButton = find.byTooltip('Iniciar Sesión');
      expect(appBarLoginButton, findsOneWidget);

      // 3. Tocar el botón de login en la AppBar de HomeScreen para ir a LoginScreen
      await tester.tap(appBarLoginButton);
      await tester.pumpAndSettle(); // Esperar la navegación

      // 4. Verificar que estamos en LoginScreen
      //    El título del AppBar de LoginScreen es 'Iniciar Sesión'
      expect(find.text('Iniciar Sesión'), findsNWidgets(2)); // AppBar title + Button text
      expect(find.widgetWithText(TextFormField, 'Correo electrónico'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Contraseña'), findsOneWidget);
    });

    testWidgets('Login with invalid credentials shows error message',
        (WidgetTester tester) async {
      // 1. Arranca la aplicación.
      app.main();
      await tester.pumpAndSettle();

      // 2. Navegar a LoginScreen (asumiendo que estamos en HomeScreen inicialmente)
      final appBarLoginButton = find.byTooltip('Iniciar Sesión');
      await tester.tap(appBarLoginButton);
      await tester.pumpAndSettle();

      // 3. Encontrar los campos y el botón de login
      final emailField = find.widgetWithText(TextFormField, 'Correo electrónico');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      final loginButton = find.widgetWithText(ElevatedButton, 'INICIAR SESIÓN');

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      // 4. Ingresar credenciales incorrectas
      await tester.enterText(emailField, invalidTestEmail);
      await tester.enterText(passwordField, invalidTestPassword);
      await tester.pump(); // Para que los controladores se actualicen

      // 5. Tocar el botón de login
      await tester.tap(loginButton);
      await tester.pumpAndSettle(); // Esperar a que se procese el login y aparezca el error

      // 6. Verificar que se muestra un mensaje de error
      //    Los mensajes de error pueden ser 'Usuario no encontrado', 'Contraseña incorrecta', etc.
      //    Buscamos por un texto parcial del mensaje de error esperado.
      //    _getErrorMessage puede devolver 'Usuario no encontrado' o 'Error al iniciar sesión'
      expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              (widget.data!.contains('Usuario no encontrado') ||
                  widget.data!.contains('Contraseña incorrecta') ||
                  widget.data!.contains('Error al iniciar sesión'))),
          findsOneWidget);

      // 7. Verificar que seguimos en la pantalla de Login
      expect(loginButton, findsOneWidget);
    });

    testWidgets('Login with valid credentials navigates to MainNavigationWrapper',
        (WidgetTester tester) async {
      // 1. Arranca la aplicación.
      app.main();
      await tester.pumpAndSettle();

      // 2. Navegar a LoginScreen
      final appBarLoginButton = find.byTooltip('Iniciar Sesión');
      await tester.tap(appBarLoginButton);
      await tester.pumpAndSettle();

      // 3. Encontrar los campos y el botón de login
      final emailField = find.widgetWithText(TextFormField, 'Correo electrónico');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      final loginButton = find.widgetWithText(ElevatedButton, 'INICIAR SESIÓN');

      // 4. Ingresar credenciales válidas
      await tester.enterText(emailField, validTestEmail);
      await tester.enterText(passwordField, validTestPassword);
      await tester.pump();

      // 5. Tocar el botón de login
      await tester.tap(loginButton);
      //    Esperar un poco más aquí porque Firebase Auth y la navegación pueden tardar.
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 6. Verificar que ya NO estamos en LoginScreen (el botón de login ya no debería estar)
      expect(loginButton, findsNothing);

      // 7. Verificar que hemos navegado a MainNavigationWrapper.
      //    AuthWrapper redirige a '/main', que carga MainNavigationWrapper.
      //    MainNavigationWrapper tiene un BottomNavigationBar.
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      //    La primera pantalla en MainNavigationWrapper es HomeScreen.
      //    Cuando un usuario está logueado, HomeScreen muestra "¡Bienvenido, [nombreUsuario]!"
      //    El nombre de usuario se toma del email antes del @.
      final welcomeMessagePrefix = validTestEmail.split('@')[0];
      expect(find.textContaining('¡Bienvenido, $welcomeMessagePrefix!'), findsOneWidget);
      
      //    También podemos buscar el botón de diccionario que está en HomeScreen.
      expect(find.widgetWithText(ElevatedButton, 'DICCIONARIO QUECHUA-ESPAÑOL'), findsOneWidget);

      // 8. MUY IMPORTANTE: Cerrar sesión para no afectar otras pruebas o el uso manual.
      //    Podemos hacerlo buscando el avatar y el diálogo de logout, o directamente.
      //    Para simplificar, usaremos FirebaseAuth.instance.signOut()
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
        await tester.pumpAndSettle(const Duration(seconds: 1)); // Dar tiempo a que se actualice
      }
    });

    testWidgets('Redirects to /main if user is already logged in',
        (WidgetTester tester) async {
      // 1. Loguear un usuario programáticamente ANTES de iniciar la app para la prueba.
      //    Esto simula un usuario que ya tenía una sesión activa.
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: validTestEmail,
          password: validTestPassword,
        );
      } catch (e) {
        // Si el usuario de prueba no existe, esta prueba fallará aquí.
        // Considera crear el usuario si no existe, o asegúrate de que exista.
        fail('Fallo al iniciar sesión con el usuario de prueba: $e. Asegúrate de que el usuario exista.');
      }
      expect(FirebaseAuth.instance.currentUser, isNotNull, reason: "El usuario de prueba no pudo iniciar sesión.");


      // 2. Arrancar la aplicación.
      app.main();
      //    AuthWrapper debería detectar al usuario logueado y redirigir a '/main'.
      //    pumpAndSettle esperará a que esta navegación se complete.
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 3. Verificar que NO estamos en LoginScreen ni en la HomeScreen inicial (sin login).
      expect(find.widgetWithText(ElevatedButton, 'INICIAR SESIÓN'), findsNothing); // Botón de LoginScreen
      expect(find.byTooltip('Iniciar Sesión'), findsNothing); // Botón de login en AppBar de HomeScreen (no logueado)


      // 4. Verificar que estamos en MainNavigationWrapper (similar al test anterior).
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      final welcomeMessagePrefix = validTestEmail.split('@')[0];
      expect(find.textContaining('¡Bienvenido, $welcomeMessagePrefix!'), findsOneWidget);

      // 5. Cerrar sesión.
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
    });
  });
}