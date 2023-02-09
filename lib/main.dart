import 'package:flutter/material.dart';
import 'package:hws_app/ui/pages/auth/login.dart';
import 'package:hws_app/global_data.dart';
import 'package:hws_app/router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'cubit/case_type_cubit.dart';
import 'cubit/user_cubit.dart';
import 'models/user.dart';

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'config/theme.dart';
import 'cubit/theme_cubit.dart';
import 'ui/screens/skeleton_screen.dart';

void main() async {
  /// Initialize packages
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
  final Directory tmpDir = await getTemporaryDirectory();
  Hive.init(tmpDir.toString());
  final HydratedStorage storage = await HydratedStorage.build(
    storageDirectory: tmpDir,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox('userBox');

  HydratedBlocOverrides.runZoned(
        () => runApp(
      EasyLocalization(
        path: 'assets/translations',
        supportedLocales: const <Locale>[
          Locale('en'),
          Locale('zh'),
        ],
        fallbackLocale: const Locale('zh'),
        useFallbackTranslations: true,
        child: const MyApp(),
      ),
    ),
    storage: storage,
  );
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (BuildContext context) => ThemeCubit(),
        ),
        BlocProvider<UserCubit>(
          create: (BuildContext context) => UserCubit(),
        ),
        BlocProvider<CaseTypeCubit>(
          create: (BuildContext context) => CaseTypeCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeModeState>(
      builder: (BuildContext context, ThemeModeState state) {
        return BlocBuilder<UserCubit, UserState>(
          builder: (BuildContext context, UserState user) {
            return GlobalData(
                child: MaterialApp(
                  /// Localization is not available for the title.
                  title: 'Hwacom App',
                  /// Theme stuff
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: state.themeMode,
                  /// Localization stuff
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  debugShowCheckedModeBanner: false,
                  home: const LoginScreen(),
                  onGenerateRoute: AppRouter.generateRoute,
                  initialRoute: '/',
              ),
            );
          },
        );
      },
    ),
    );
  }
}




