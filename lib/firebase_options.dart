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
    apiKey: 'PASTE_API_KEY_DARI_YOUR_APPS_DISINI',
    appId: 'PASTE_APP_ID_DARI_YOUR_APPS_DISINI',
    messagingSenderId: '651310592592', // Sesuai Project Number kamu
    projectId: 'smart-locker-iot-10a0e', // Project ID yang benar!
    authDomain: 'smart-locker-iot-10a0e.firebaseapp.com',
    storageBucket: 'smart-locker-iot-10a0e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PASTE_API_KEY_DARI_YOUR_APPS_DISINI',
    appId: 'PASTE_APP_ID_ANDROID_DISINI',
    messagingSenderId: '651310592592',
    projectId: 'smart-locker-iot-10a0e',
    storageBucket: 'smart-locker-iot-10a0e.firebasestorage.app',
  );
}