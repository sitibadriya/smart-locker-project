import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk platform ini.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDLZr4hM-aYSckpFVSYZilsJAhgQqsK0yE',
    appId: '1:651310592592:web:d34f6f7012b9eb56251755',
    messagingSenderId: '651310592592', // Sesuai Project Number kamu
    projectId: 'smart-locker-iot-10a0e', // Project ID yang benar!
    authDomain: 'smart-locker-iot-10a0e.firebaseapp.com',
    storageBucket: 'smart-locker-iot-10a0e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDLZr4hM-aYSckpFVSYZilsJAhgQqsK0yE',
    appId: '1:651310592592:android:7f61911df90b8cfa251755',
    messagingSenderId: '651310592592',
    projectId: 'smart-locker-iot-10a0e',
    storageBucket: 'smart-locker-iot-10a0e.firebasestorage.app',
  );
}
