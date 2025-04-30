import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram/features/auth/presentation/pages/auth_page.dart';
import 'package:instagram/firebase_options.dart';
import 'package:instagram/theme/light_mode.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
  
    const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //! This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightMode,
      home: AuthPage(),
    );}}