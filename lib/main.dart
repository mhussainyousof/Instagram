import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram/features/auth/presentation/pages/auth_page.dart';
import 'package:instagram/firebase_options.dart';
import 'package:instagram/instagram.dart';
import 'package:instagram/theme/light_mode.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
  
    const MyApp());
}

