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


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'What Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
              color: Colors.black, fontWeight: FontWeight.normal, fontSize: 19),
          backgroundColor: Colors.white,
        )),
        home: const SplashScreen());
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // var result = await FlutterNotificationChannel.registerNotificationChannel(
  //     description: 'Para mostrar notificaciones de mensajes',
  //     id: 'chats',
  //     importance: NotificationImportance.IMPORTANCE_HIGH,
  //     name: 'Chats');
  // log('\nResultado del canal de notificación: $result');
}
