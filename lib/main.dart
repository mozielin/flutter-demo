import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hws_app/service/authenticate/auth.dart';

import 'package:hws_app/ui/pages/auth/login.dart';
import 'package:hws_app/global_data.dart';
import 'package:hws_app/router.dart';
import 'package:hws_app/ui/widgets/alert/icons/error_icon.dart';
import 'package:hws_app/ui/widgets/alert/styles.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:secure_application/secure_application.dart';
import 'cubit/user_cubit.dart';
import 'models/user.dart';
import 'dart:io';

import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:path_provider/path_provider.dart';

import 'config/theme.dart';
import 'cubit/theme_cubit.dart';

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
        child: MyApp(),
      ),
    ),
    storage: storage,
  );
  // runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.inactive) {

    }
    if (state == AppLifecycleState.resumed){
      print('resumed');

    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

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
                    builder: (context, child) => SecureApplication(
                      nativeRemoveDelay: 800,
                      onNeedUnlock: (secureApplicationController) async {
                        AuthService().verifyToken(user.token).then((res) {
                          if (res['success']) {
                            var token = res['token'];
                            BlocProvider.of<UserCubit>(context).refreshToken(user, token);
                            print("Token refresh : $token");
                            return SecureApplicationAuthenticationStatus.SUCCESS;
                          } else {
                            print("Token EXP");
                            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                            return SecureApplicationAuthenticationStatus.FAILED;
                            ///Alert token expired return to login
                          }
                        }).onError((error, stackTrace) {
                          print(error);
                          return SecureApplicationAuthenticationStatus.FAILED;
                        });
                        return null;
                      },
                      child: child!,
                    ),
                  ),
                );
              },
            );
          },
        )
    );
  }
}




