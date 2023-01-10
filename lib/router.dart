// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hws_app/ui/pages/common/photo_detail_base64.dart';
import 'package:hws_app/ui/pages/home_page.dart';
import 'package:hws_app/ui/pages/api_demo.dart';
import 'package:hws_app/ui/pages/hive_demo.dart';
import 'package:hws_app/ui/pages/clock/list.dart';
import 'package:hws_app/ui/pages/file_demo.dart';

class RouteName {
  static const String home = '/';
  static const String demo = '/api_demo';
  static const String hive = '/hive_demo';
  static const String clock = '/clock_demo';
  static const String file = '/file_demo';
  static const String photo_detail_base64 = '/photo_detail_base64';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.home:
        return CupertinoPageRoute(
            builder: (context) => const HomePage(
                  title: 'MainPage',
                ));
      case RouteName.demo:
        return CupertinoPageRoute(builder: (context) => ApiDemo());
      case RouteName.hive:
        return CupertinoPageRoute(builder: (context) => HiveDemo());
      case RouteName.clock:
        return CupertinoPageRoute(builder: (context) => ClockDemo());
      case RouteName.file:
        return CupertinoPageRoute(builder: (context) => FileDemo());
      case RouteName.photo_detail_base64:
        return CupertinoPageRoute(builder: (context) => PhotoDetailBase64());
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
