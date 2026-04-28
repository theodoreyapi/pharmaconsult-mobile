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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC2KLacO40EHg9zFYDngKlZqll6nySDegI',
    appId: '1:748172317271:web:ae6fe6a21a61bce5968912',
    messagingSenderId: '748172317271',
    projectId: 'pharmaconsults-f209a',
    authDomain: 'pharmaconsults-f209a.firebaseapp.com',
    storageBucket: 'pharmaconsults-f209a.firebasestorage.app',
    measurementId: 'G-63SSR08X1P',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAlCC7qklu1DCqhfq1Z9qcVlO7NNbE9uqg',
    appId: '1:748172317271:android:33e341b4f7fdf283968912',
    messagingSenderId: '748172317271',
    projectId: 'pharmaconsults-f209a',
    storageBucket: 'pharmaconsults-f209a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATF1ltoRLkwRfUsIC2gDp9KF4H0dxtmkw',
    appId: '1:748172317271:ios:906a7ecc8ce74909968912',
    messagingSenderId: '748172317271',
    projectId: 'pharmaconsults-f209a',
    storageBucket: 'pharmaconsults-f209a.firebasestorage.app',
    iosBundleId: 'com.aptiotech.pharmaconsult.yapi.pharmaconsult',
  );

}