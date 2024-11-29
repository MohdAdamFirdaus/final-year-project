// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB81Eno_P5W2k5v0cQvs1JAeJ4r-KBH4xk',
    appId: '1:120599433996:web:4f100e2cdb0dc996dbef29',
    messagingSenderId: '120599433996',
    projectId: 'fyp2-project-e1f26',
    authDomain: 'fyp2-project-e1f26.firebaseapp.com',
    storageBucket: 'fyp2-project-e1f26.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVOTQo5xVc6t7DTfpWjmN4wYG4ToxJrys',
    appId: '1:120599433996:android:97bcf85eca0ab44edbef29',
    messagingSenderId: '120599433996',
    projectId: 'fyp2-project-e1f26',
    storageBucket: 'fyp2-project-e1f26.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIu1TrQKD1FH899WV7tjp9C4VNN_YCmq4',
    appId: '1:120599433996:ios:51001f3de0c31811dbef29',
    messagingSenderId: '120599433996',
    projectId: 'fyp2-project-e1f26',
    storageBucket: 'fyp2-project-e1f26.appspot.com',
    iosBundleId: 'com.example.fyp2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCIu1TrQKD1FH899WV7tjp9C4VNN_YCmq4',
    appId: '1:120599433996:ios:51001f3de0c31811dbef29',
    messagingSenderId: '120599433996',
    projectId: 'fyp2-project-e1f26',
    storageBucket: 'fyp2-project-e1f26.appspot.com',
    iosBundleId: 'com.example.fyp2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB81Eno_P5W2k5v0cQvs1JAeJ4r-KBH4xk',
    appId: '1:120599433996:web:1b98bdab4c02b66fdbef29',
    messagingSenderId: '120599433996',
    projectId: 'fyp2-project-e1f26',
    authDomain: 'fyp2-project-e1f26.firebaseapp.com',
    storageBucket: 'fyp2-project-e1f26.appspot.com',
  );
}