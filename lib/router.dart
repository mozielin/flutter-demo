import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hws_app/pages/home_page.dart';
import 'package:hws_app/pages/route_demo.dart';

class RouteName {
  static const String home = '/';
  static const String demo = '/route_demo';

}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.home:
        return CupertinoPageRoute(builder: (context) => const HomePage(title: 'MainPage',) );
      case RouteName.demo:
        return CupertinoPageRoute(builder: (context) => const RouteDemo(title: 'Demo',));
      default:
        return CupertinoPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('No route defined for ${settings.name}'),
              ),
            ));
    }
  }
}
