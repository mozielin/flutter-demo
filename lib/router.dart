import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hws_app/ui/pages/home_page.dart';
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
  static const String clock = '/clock_demo';
  static const String file = '/file_demo';
  static const String login = '/login';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // case RouteName.home:
    //   return CupertinoPageRoute(
    //       builder: (context) => const LoginScreen());
      case RouteName.home:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SkeletonScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(-2, 0); //start position from top and left corner f.e.
              var end = Offset.zero;
              var curve = Curves.easeOut;

              var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
             },
            transitionDuration: const Duration(milliseconds:1500) //any duration you want
        );

      case RouteName.demo:
        return CupertinoPageRoute(builder: (context) => ApiDemo());
      case RouteName.hive:
        return CupertinoPageRoute(builder: (context) => HiveDemo());
      case RouteName.file:
        return CupertinoPageRoute(builder: (context) => FileDemo());
      case RouteName.clock:
        return CupertinoPageRoute(builder: (context) => ClockDemo());
      case RouteName.login:
        return CupertinoPageRoute(builder: (context) => LoginScreen());
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
