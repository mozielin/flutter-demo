import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hws_app/ui/pages/home_page.dart';
import 'package:hws_app/ui/pages/api_demo.dart';
import 'package:hws_app/ui/pages/hive_demo.dart';
import 'package:hws_app/ui/pages/clock_demo.dart';

class RouteName {
  static const String home = '/';
  static const String demo = '/api_demo';
  static const String hive = '/hive_demo';
  static const String clock = '/clock_demo';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.home:
        return CupertinoPageRoute(builder: (context) => const HomePage(title: 'MainPage',) );
      case RouteName.demo:
        return CupertinoPageRoute(builder: (context) => ApiDemo());
      case RouteName.hive:
        return CupertinoPageRoute(builder: (context) => HiveDemo());
      case RouteName.clock:
        return CupertinoPageRoute(builder: (context) => ClockDemo());
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
