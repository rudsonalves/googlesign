import 'package:flutter/material.dart';

class SignInWidget extends StatelessWidget {
  final void Function()? onSignIn;

  const SignInWidget({
    super.key,
    this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Text('You are not currently signed in.'),
        ElevatedButton.icon(
          onPressed: onSignIn,
          icon: const Icon(Icons.login),
          label: const Text('SIGN IN'),
        ),
      ],
    );
  }
}
