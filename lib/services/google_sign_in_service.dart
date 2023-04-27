// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
// import 'dart:convert' show json;
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// The scopes required by this application.
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

class GoogleSignInService {
  GoogleSignInAccount? _currentUser;
  ValueNotifier<bool> isAuthorized$ = ValueNotifier(false);
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: scopes,
  );

  GoogleSignInService();

  Future<void> _refreshAuthorization() async {
    GoogleSignInAccount? account = _googleSignIn.currentUser;
    bool isAuthorized = (account != null);

    if (kIsWeb && account != null) {
      isAuthorized = await _googleSignIn.canAccessScopes(scopes);
    }

    _currentUser = account;
    isAuthorized$.value = isAuthorized;

    if (isAuthorized) {
      _handleGetContact(account!);
    }
    log('isAuthorized: ${isAuthorized$.value}');
  }

  Future<void> _setConnection() async {
    await _refreshAuthorization();
    try {
      await _googleSignIn.signInSilently();
    } catch (err) {
      log(err.toString());
    }
  }

  bool get isAuthorized => isAuthorized$.value;

  GoogleSignInAccount? get currentUser => _currentUser;

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );

    if (response.statusCode != 200) {
      log('People API ${response.statusCode} response: ${response.body}');
      return;
    }
  }

  List<String> get contactsList {
    return <String>[];
  }

  // Future<void> handleAuthorizeScopes() async {
  //   final bool isAuthorized = await _googleSignIn.requestScopes(scopes);

  //   isAuthorized$.value = isAuthorized;

  //   // if (isAuthorized) {
  //   //   _handleGetContact(_currentUser!);
  //   // }
  // }

  Future<void> handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      await _setConnection();
      log('Sign In Google.com...');
    } catch (error) {
      log(error.toString());
    }
  }

  Future<void> handleSignOut() async {
    await _googleSignIn.disconnect();
    await _setConnection();
    log('Sign OUT from Google.com...');
  }
}
