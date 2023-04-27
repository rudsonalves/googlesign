import 'dart:developer';

import 'package:flutter/material.dart';

import '../services/google_sign_in_service.dart';
import '../components/sign_in_widget.dart';
import '../components/sign_out_widget.dart';

class SignInGooglePage extends StatefulWidget {
  const SignInGooglePage({super.key});

  @override
  State<SignInGooglePage> createState() => _SignInGooglePageState();
}

class _SignInGooglePageState extends State<SignInGooglePage> {
  late GoogleSignInService googleSignIn = GoogleSignInService();

  @override
  Widget build(BuildContext context) {
    if (googleSignIn.isAuthorized) {
      googleSignIn.handleSignOut();
      log('SIGN OUT...');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign In'),
      ),
      body: ValueListenableBuilder(
        builder: (BuildContext context, value, Widget? child) {
          if (value) {
            return Center(
              child: SignOutWidget(
                onSignOut: googleSignIn.handleSignOut,
                user: googleSignIn.currentUser,
              ),
            );
          } else {
            return Center(
              child: SignInWidget(
                onSignIn: googleSignIn.handleSignIn,
              ),
            );
          }
        },
        valueListenable: googleSignIn.isAuthorized$,
      ),
    );
  }
}
