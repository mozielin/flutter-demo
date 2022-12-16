import 'package:flutter/material.dart';
import 'package:hws_app/pages/home_page.dart';
import 'package:hws_app/router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user.dart';

void main()async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox('userBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
    );
  }
}


