import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './modules/text2Sign.dart';
import './modules/thelivecam.dart';
import './modules/screenRecog.dart';
import 'modules/signin_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      routes: {
        TheCam.routeName: (context) => TheCam(),
        SpeechRecognitionScreen.routename: (context) =>
            SpeechRecognitionScreen(),
        textToSign.routename: (context) => textToSign()
      },
    );
  }
}
