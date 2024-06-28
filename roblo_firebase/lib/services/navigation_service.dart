import 'package:flutter/material.dart';
import 'package:roblo_firebase/pages/home_page.dart';
import 'package:roblo_firebase/pages/login_page.dart';
import 'package:roblo_firebase/pages/profile_page.dart';
import 'package:roblo_firebase/pages/register_page.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => LoginPage(),
    "/register": (context) => RegisterPage(),
    "/home": (context) => HomePage(),
    "/profile": (context) => ProfilePage(),
  };

  GlobalKey<NavigatorState>? get navigatorKey {
    return _navigatorKey;
  }

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  void pushNamed(String routerName) {
    _navigatorKey.currentState?.pushNamed(routerName);
  }

  void pushReplaceMentNamed(String routerName) {
    _navigatorKey.currentState?.pushReplacementNamed(routerName);
  }

  void goback() {
    _navigatorKey.currentState?.pop();
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }
}
