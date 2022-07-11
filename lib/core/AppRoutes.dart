import 'package:flutter/material.dart';

import '../model/usuario_model.dart';
import '../pages/error_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/messages_page.dart';
import '../pages/register_page.dart';
import '../pages/settings_page.dart';

class AppRoutes {
  static String home = '/home';
  static String login = '/login';
  static String register = '/register';
  static String settings = '/settings';
  static String messages = '/messages';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case "/login":
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case "/register":
        return MaterialPageRoute(builder: (context) => const RegisterPage());
      case "/home":
        return MaterialPageRoute(builder: (context) => const HomePage());
      case "/settings":
        return MaterialPageRoute(builder: (context) => const SettingsPage());
      case "/messages":
        return MaterialPageRoute(
            builder: (context) => MessagesPage(args as UsuarioModel));
      default:
        return MaterialPageRoute(builder: (context) => const ErrorPage());
    }
  }
}
