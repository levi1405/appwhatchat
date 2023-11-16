// Importa paquetes necesarios para el manejo de datos, autenticación, almacenamiento, y notificaciones en Firebase.
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

// Importa modelos de usuario y mensaje.
import '../models/chat_user.dart';
import '../models/message.dart';

// Clase que proporciona métodos y variables para interactuar con Firebase y realizar operaciones en la base de datos.
class APIs {
  // Para autenticación.
  static FirebaseAuth auth = FirebaseAuth.instance;

  // Para acceder a la base de datos Cloud Firestore.
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Para acceder al almacenamiento de Firebase.
  static FirebaseStorage storage = FirebaseStorage.instance;

  // Usuario actual.
  static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, estoy usando What Chat!",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');

  // Método getter para obtener el usuario actual.
  static User get user => auth.currentUser!;

  // Para acceder a las notificaciones de Firebase (Push Notification).
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // Método para obtener el token de notificaciones de Firebase.
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAANeH3LLQ:APA91bHvdxtNehSozHkq4uwITq9PHQReH4zdFftHGo65uwf17TAwXoIMrG3Y6nqNikG3_MKDJfkYAnQM_RWbsH434hd1ZxoZlIyIBnzBGvPfMKVtjdQ6lnNi0p_Rg0nViU-fUZYTQOze'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // Método para verificar si un usuario existe.
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // Método para agregar un usuario a la lista de contactos.
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      // El usuario existe.
      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      // El usuario no existe.
      return false;
    }
  }

  // Método para obtener la información del usuario actual.
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        // Para establecer el estado del usuario como activo.
        APIs.updateActiveStatus(true);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // Método para crear un nuevo usuario.
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, estoy usando What Chat!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // Método para obtener los IDs de los usuarios conocidos desde la base de datos de Firestore.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // Método para obtener todos los usuarios desde la base de datos de Firestore.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) // porque la lista vacía arroja un error
        .snapshots();
  }

  // Método para enviar el primer mensaje a un usuario.
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // Método para actualizar la información del usuario.
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // Método para actualizar la imagen de perfil del usuario.
  static Future<void> updateProfilePicture(File file) async {
    // Obtener la extensión del archivo de imagen.
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    // Referencia al archivo en el almacenamiento.
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    // Subir la imagen al almacenamiento.
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    // Actualizar la URL de la imagen en la base de datos de Firestore.
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // Método para obtener información específica de un usuario.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // Método para actualizar el estado en línea o el estado de la última actividad del usuario.
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///************** APIs relacionadas con la pantalla de chat **************

  // chats (colección) --> conversation_id (documento) --> messages (colección) --> message (documento)

  // Método útil para obtener el ID de la conversación.
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // Método para obtener todos los mensajes de una conversación específica desde la base de datos de Firestore.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // Método para enviar un mensaje.
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    // Hora de envío del mensaje (también se usa como identificación única).
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // Mensaje a enviar.
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  // Método para actualizar el estado de lectura de un mensaje.
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // Método para obtener solo el último mensaje de una conversación específica.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // Método para enviar una imagen en el chat.
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    // Obtener la extensión del archivo de imagen.
    final ext = file.path.split('.').last;

    // Referencia al archivo en el almacenamiento.
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    // Subir la imagen al almacenamiento.
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    // Actualizar la URL de la imagen en la base de datos de Firestore y enviar el mensaje.
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  // Método para eliminar un mensaje.
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  // Método para actualizar un mensaje.
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
