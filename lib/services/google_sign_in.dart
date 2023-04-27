import 'dart:async';
import 'dart:convert' show json;
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// The scopes required by this application.
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

enum GoogleSignStatus {
  loading,
  error,
  connected,
  notConnected,
}

class MyGoogleSignIn {
  ValueNotifier<GoogleSignStatus> status =
      ValueNotifier(GoogleSignStatus.notConnected);
  GoogleSignInAccount? _currentUser;
  ValueNotifier<bool> _isAuthorized =
      ValueNotifier(false); // has granted permissions?
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: 'your-client_id.apps.googleusercontent.com',
    scopes: scopes,
  );

  MyGoogleSignIn() {
    _googleSignIn.onCurrentUserChanged.listen(
      (GoogleSignInAccount? account) async {
        // In mobile, being authenticated means being authorized...
        bool isAuthorized = account != null;
        // However, in the web...
        if (kIsWeb && account != null) {
          isAuthorized = await _googleSignIn.canAccessScopes(scopes);
        }

        _currentUser = account;
        _isAuthorized = ValueNotifier(isAuthorized);

        // Now that we know that the user can access the required scopes, the app
        // can call the REST API.
        if (isAuthorized) {
          handleGetContact(account!);
        }
      },
    );

    // In the web, _googleSignIn.signInSilently() triggers the One Tap UX.
    //
    // It is recommended by Google Identity Services to render both the One Tap UX
    // and the Google Sign In button together to "reduce friction and improve
    // sign-in rates" ([docs](https://developers.google.com/identity/gsi/web/guides/display-button#html)).
    _googleSignIn.signInSilently();
  }

  bool get isAuthorized => _isAuthorized as bool;
  GoogleSignInAccount? get currentUser => _currentUser;

  // Calls the People API REST endpoint for the signed-in user to retrieve information.
  Future<void> handleGetContact(GoogleSignInAccount user) async {
    status = ValueNotifier(GoogleSignStatus.loading);

    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );

    if (response.statusCode != 200) {
      status = ValueNotifier(GoogleSignStatus.error);

      log('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    status = ValueNotifier(GoogleSignStatus.connected);

    // final Map<String, dynamic> data =
    //     json.decode(response.body) as Map<String, dynamic>;
    // final String? namedContact = _pickFirstNamedContact(data);

    // if (namedContact != null) {
    // } else {
    //   status = GoogleSignStatus.notConnected;
    // }
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final List<dynamic> names = contact['names'] as List<dynamic>;
      final Map<String, dynamic>? name = names.firstWhere(
        (dynamic name) =>
            (name as Map<Object?, dynamic>)['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  // This is the on-click handler for the Sign In button that is rendered by Flutter.
  //
  // On the web, the on-click handler of the Sign In button is owned by the JS
  // SDK, so this method can be considered mobile only.
  Future<void> handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      log(error.toString());
    }
  }

  // Prompts the user to authorize `scopes`.
  //
  // This action is **required** in platforms that don't perform Authentication
  // and Authorization at the same time (like the web).
  //
  // On the web, this must be called from an user interaction (button click).
  Future<void> handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);

    _isAuthorized = ValueNotifier(isAuthorized);

    if (isAuthorized) {
      handleGetContact(_currentUser!);
    }
  }

  Future<void> handleSignOut() => _googleSignIn.disconnect();
}
