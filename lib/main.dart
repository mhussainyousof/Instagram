import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/config/firebase_options.dart';
import 'package:instagram/instagram.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   await GoogleFonts.pendingFonts([  
    GoogleFonts.firaCode(),
  ]);
  runApp(
     MyApp());
}

