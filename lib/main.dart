import 'dart:developer';

import 'package:appwhatchat/firebase_options.dart';
import 'package:appwhatchat/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';

//global object for accessing device screen size
late Size mq;

// Función principal 'main' que se ejecuta al iniciar la aplicación.
void main() {
  // Asegura que se hayan inicializado los enlaces de widgets de Flutter antes de ejecutar la aplicación.
  WidgetsFlutterBinding.ensureInitialized();

  // Configura el sistema para habilitar el modo de IU inmersiva y pegajosa.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Configura las orientaciones preferidas de la pantalla (solo en modo retrato) y luego ejecuta el código en el bloque 'then'.
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    // Llama a la función para inicializar Firebase.
    _initializeFirebase();

    // Ejecuta la aplicación Flutter 'MyApp'.
    runApp(const MyApp());
  });
}

// Clase 'MyApp' que representa la aplicación Flutter.
class MyApp extends StatelessWidget {
  // Constructor constante para la clase 'MyApp'.
  const MyApp({super.key});

  // Método 'build' que construye la interfaz de usuario de la aplicación.
  @override
  Widget build(BuildContext context) {
    // Devuelve un objeto 'MaterialApp' que define la estructura y el tema de la aplicación.
    return MaterialApp(
        // Título de la aplicación.
        title: 'What Chat',

        // Oculta el banner de depuración en la esquina superior derecha.
        debugShowCheckedModeBanner: false,

        // Tema de la aplicación que define la apariencia general de la interfaz de usuario.
        theme: ThemeData(
            // Tema de la barra de aplicación.
            appBarTheme: const AppBarTheme(
          // Centra el título en la barra de aplicación.
          centerTitle: true,

          // Elevación de la barra de aplicación (sombra).
          elevation: 1,

          // Configuración del tema de los iconos en la barra de aplicación.
          iconTheme: IconThemeData(color: Colors.black),

          // Estilo del texto del título en la barra de aplicación.
          titleTextStyle: TextStyle(
              color: Colors.black, fontWeight: FontWeight.normal, fontSize: 19),

          // Color de fondo de la barra de aplicación.
          backgroundColor: Colors.white,
        )),

        // Página de inicio de la aplicación, en este caso, se establece como la pantalla de presentación 'SplashScreen'.
        home: const SplashScreen());
  }
}

// Función privada '_initializeFirebase' para inicializar Firebase de forma asíncrona.
_initializeFirebase() async {
  // Espera a que la inicialización de Firebase se complete.
  // 'options' se utiliza para proporcionar opciones de configuración adicionales, en este caso, utiliza las opciones predeterminadas para la plataforma actual.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // var result = await FlutterNotificationChannel.registerNotificationChannel(
  //     description: 'Para mostrar notificaciones de mensajes',
  //     id: 'chats',
  //     importance: NotificationImportance.IMPORTANCE_HIGH,
  //     name: 'Chats');
  // log('\nResultado del canal de notificación: $result');
}
