// Importa el paquete Flutter para la construcción de interfaces de usuario.
import 'package:flutter/material.dart';

// Clase que contiene métodos estáticos para mostrar mensajes emergentes en la interfaz de usuario.
class Dialogs {
  // Método para mostrar un mensaje emergente (Snackbar) en la interfaz de usuario.
  static void showSnackbar(BuildContext context, String msg) {
    // Utiliza el objeto ScaffoldMessenger para mostrar un Snackbar en el contexto proporcionado.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),  // Contenido del Snackbar, el mensaje proporcionado.
        backgroundColor: Colors.blue.withOpacity(.8),  // Color de fondo del Snackbar.
        behavior: SnackBarBehavior.floating));  // Comportamiento del Snackbar, en este caso, flotante.
  }

  // Método para mostrar una barra de progreso (CircularProgressIndicator) en la interfaz de usuario.
  static void showProgressBar(BuildContext context) {
    // Muestra un diálogo con un indicador de progreso circular en el centro de la pantalla.
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
