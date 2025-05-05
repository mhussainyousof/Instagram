import 'package:flutter/material.dart';
import 'package:instagram/features/auth/presentation/pages/login_page.dart';
import 'package:instagram/features/auth/presentation/pages/register_page.dart';
import 'package:instagram/responsive/constrained_scaffold.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  //! initially, show login page
  bool showLoginPage = true;

  //! toggle between pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: showLoginPage 
          ? LoginPage(togglePages: togglePages,) 
          : RegisterPage(togglePages: togglePages,),
      ),
    );
  }
}