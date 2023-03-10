// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hws_app/ui/pages/clock/create.dart';
import 'package:hws_app/ui/pages/clock_info_demo.dart';
import 'package:hws_app/ui/pages/common/photo_detail_base64.dart';
import 'package:hws_app/ui/pages/api_demo.dart';
import 'package:hws_app/ui/pages/hive_demo.dart';
import 'package:hws_app/ui/pages/clock/list.dart';
import 'package:hws_app/ui/pages/file_demo.dart';
import 'package:hws_app/ui/pages/auth/login.dart';
import 'package:hws_app/ui/screens/skeleton_screen.dart';

class RouteName {
  static const String home = '/home';
  static const String demo = '/api_demo';
  static const String hive = '/hive_demo';
  static const String clock = '/clock_list';
  static const String file = '/file_demo';
  static const String photo_detail_base64 = '/photo_detail_base64';
  static const String login = '/login';
  static const String create_clock = '/create_clock';
  static const String clock_info = '/clock_info_demo';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.home:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SkeletonScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = const Offset(-2, 0); //start position from top and left corner f.e.
              var end = Offset.zero;
              var curve = Curves.easeOut;

              var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
             },
            transitionDuration: const Duration(milliseconds:500) //any duration you want
        );

      case RouteName.demo:
        return CupertinoPageRoute(builder: (context) => const ApiDemo());
      case RouteName.hive:
        return CupertinoPageRoute(builder: (context) => const HiveDemo());
      case RouteName.clock_info:
        return CupertinoPageRoute(builder: (context) => const ClockInfoDemo());
      case RouteName.file:
        return CupertinoPageRoute(builder: (context) => const FileDemo());
      case RouteName.clock:
        return CupertinoPageRoute(builder: (context) => const ClockDemo());
      case RouteName.photo_detail_base64:
        return CupertinoPageRoute(builder: (context) => const PhotoDetailBase64());
      case RouteName.login:
        return CupertinoPageRoute(builder: (context) => const LoginScreen());
      case RouteName.create_clock:
        return CupertinoPageRoute(builder: (context) => CreateClock(), settings: settings);
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
