import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignOutWidget extends StatelessWidget {
  final void Function() onSignOut;
  final GoogleSignInAccount? user;

  const SignOutWidget({
    super.key,
    required this.onSignOut,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (user != null)
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user!,
            ),
            title: Text(
              user!.displayName ??
                  user!.email.substring(0, user!.email.indexOf('@')),
            ),
            subtitle: Text(user!.email),
          ),
        const Text('Signed in successfully.'),
        const Text('I see you know XXXXX'),
        ElevatedButton(
          onPressed: () {},
          child: const Text('REFRESH'),
        ),
        ElevatedButton.icon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout),
          label: const Text('SIGN OUT'),
        ),
      ],
    );
  }
}
