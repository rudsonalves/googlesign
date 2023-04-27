// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

// import 'dart:async';
// import 'dart:convert' show json;

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';

import './pages/sign_in_demo.dart';
// import 'package:http/http.dart' as http;

// import 'src/sign_in_button.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Google Sign In',
      home: SignInDemo(),
    ),
  );
}
