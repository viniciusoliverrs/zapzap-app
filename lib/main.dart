import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import './core/AppRoutes.dart';
import './pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: const Color(0xff075E54),
        secondary: const Color(0xff25d366),
      ),
    ),
    initialRoute: "/",
    onGenerateRoute: AppRoutes.generateRoute,
    debugShowCheckedModeBanner: false,
    home: const LoginPage(),
  ));
}
