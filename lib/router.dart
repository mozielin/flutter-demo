import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hws_app/pages/home_page.dart';
import 'package:hws_app/pages/api_demo.dart';
import 'package:hws_app/pages/hive_demo.dart';

class RouteName {
  static const String home = '/';
  static const String demo = '/api_demo';
  static const String hive = '/hive_demo';

}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.home:
        return CupertinoPageRoute(builder: (context) => const HomePage(title: 'MainPage',) );
      case RouteName.demo:
        return CupertinoPageRoute(builder: (context) => ApiDemo(title: 'Demo',));
      case RouteName.hive:
        return CupertinoPageRoute(builder: (context) => HiveDemo(title: 'Hive',));
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
