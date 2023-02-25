import 'package:flutter/material.dart';
import 'package:hws_app/models/clock.dart';
import 'package:hws_app/models/dispatch.dart';
import 'package:hws_app/models/supportCase.dart';
import 'package:hws_app/models/toBeSyncClock.dart';
import 'package:hws_app/models/warranty.dart';
import 'package:hws_app/ui/pages/auth/login.dart';
import 'package:hws_app/global_data.dart';
import 'package:hws_app/router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'cubit/clock_cubit.dart';
import 'cubit/user_cubit.dart';
import 'models/files.dart';
import 'models/user.dart';

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'config/theme.dart';
import 'cubit/theme_cubit.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
void main() async {
  ///TODO:優化-進入APP的LOGO顯示
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
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
  Hive.registerAdapter(ClockAdapter());
  await Hive.openBox('clockBox');
  Hive.registerAdapter(FilesAdapter());
  await Hive.openBox('filesBox');
  Hive.registerAdapter(SupportCaseAdapter());
  await Hive.openBox('supportCaseBox');
  Hive.registerAdapter(ToBeSyncClockAdapter());
  await Hive.openBox('toBeSyncClockBox');
  Hive.registerAdapter(DispatchAdapter());
  await Hive.openBox('dispatchBox');
  Hive.registerAdapter(WarrantyAdapter());
  await Hive.openBox('warrantyBox');

  ///TODO:優化-進入APP的LOGO顯示/關閉
  FlutterNativeSplash.remove();

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
        BlocProvider<ClockCubit>(
          create: (BuildContext context) => ClockCubit(),
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
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: child!,
                    );
                  },
              ),
            );
          },
        );
      },
    ),
    );
  }
}




