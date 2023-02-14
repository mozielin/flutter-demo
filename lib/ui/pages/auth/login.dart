import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hws_app/ui/widgets/auth/account_field.dart';
import 'package:hws_app/ui/widgets/auth/login_button.dart';
import 'package:hws_app/ui/widgets/auth/cutscene_screen.dart';
import 'package:hws_app/ui/widgets/auth/password_field.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:hws_app/service/authenticate/auth.dart';
import 'package:uiblock/uiblock.dart';
import '../../../cubit/theme_cubit.dart';
import '../../../cubit/user_cubit.dart';
import 'package:hws_app/ui/widgets/alert/alert_icons.dart';
import 'package:hws_app/ui/widgets/alert/styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController accountController;
  late TextEditingController passwordController;
  double _elementsOpacity = 1;
  bool loadingBallAppear = false;
  bool loginRecently = false;
  double loadingBallSize = 1;
  late String accountError = '';
  late String passwordError = '';
  late bool accountInvalid = false;
  late bool passwordInvalid = false;
  late ThemeMode mode;
  String release = "";

  basicStatusCheck(NewVersionPlus newVersion) async {
    final version = await newVersion.getVersionStatus();
    if (version != null) {
      release = version.releaseNotes ?? "";
      //setState(() {});
    }
    newVersion.showAlertIfNecessary(
      context: context,
      launchModeVersion: LaunchModeVersion.external,
    );
  }

  advancedStatusCheck(NewVersionPlus newVersion) async {
    //TODO:要求更新客製訊息
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      debugPrint(status.releaseNotes);
      debugPrint(status.appStoreLink);
      debugPrint(status.localVersion);
      debugPrint(status.storeVersion);
      debugPrint(status.canUpdate.toString());
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: 'Custom Title',
        dialogText: 'Custom Text',
      );
    }
  }

  @override
  initState() {
    // Instantiate NewVersion manager object (Using GCP Console app as example)
    //TODO:更換APPID
    final newVersion = NewVersionPlus(
        iOSId: 'com.google.Vespa',
        androidId: 'com.disney.disneyplus',
        androidPlayStoreCountry: "es_ES" //support country code
    );

    // You can let the plugin handle fetching the status and showing a dialog,
    // or you can fetch the status and display your own dialog, or no dialog.

    const simpleBehavior = true;

    // if (simpleBehavior) {
    //   basicStatusCheck(newVersion);
    // }
    // else {
    //   advancedStatusCheck(newVersion);
    // }

    accountController = TextEditingController();
    passwordController = TextEditingController();
    //透過Provider取得UserCubit狀態
    var user = BlocProvider.of<UserCubit>(context).state;
    if (user.token != '') {
      setState(() {
        loadingBallAppear = true;
      });
      // AuthService().verifyToken(user.token)
      //     .then((res) {
      //   if (res['success']) {
      //     setState(() {
      //       _elementsOpacity = 0;
      //     });
      //     var token = res['token'];
      //     BlocProvider.of<UserCubit>(context).refreshToken(user, token);
      //     print("Token refresh : $token");
      //   } else {
      //     ///Alert token expired return to login
      //     Alert(
      //       context: context,
      //       style: AlertStyles().dangerStyle(context),
      //       image: const ErrorIcon(),
      //       title: tr('alerts.token_expired_title'),
      //       desc: tr('alerts.token_expired_text'),
      //       buttons: [
      //         AlertStyles().getReturnLoginButton(context),
      //       ],
      //     ).show();
      //
      //     BlocProvider.of<UserCubit>(context).clearUser();
      //   }
      // }).onError((error, stackTrace) {
      //   print(error);
      // });
    } else {
      debugPrint('Token empty');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(builder: (BuildContext context, UserState user) {
      return BlocBuilder<ThemeCubit, ThemeModeState>(
        builder: (BuildContext context, ThemeModeState state) {
          return Scaffold(
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .background,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              bottom: false,
              child: loadingBallAppear
                  ? Padding(padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30.0), child: CutsceneScreen(loginRecently:loginRecently))
                  : Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300),
                      tween: Tween(begin: 1, end: _elementsOpacity),
                      builder: (_, value, __) =>
                          Opacity(
                            opacity: value,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ///Logo放這
                                Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      child: Theme.of(context).brightness == Brightness.dark ? getDarkLogo() : getLightLogo(),
                                  )
                                ),
                                Text(
                                  "Welcome to Hwapp",
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .titleMedium!
                                      .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                                ),
                                Text(
                                  "Sign in to continue",
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .titleMedium!
                                      .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                                ),
                              ],
                            ),
                          ),
                    ),
                    SizedBox(height: 25),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          AccountField(
                            fadeAccount: _elementsOpacity == 0,
                            accountController: accountController,
                            errorText: accountError,
                            invalid: accountInvalid,
                          ),
                          SizedBox(height: 30),
                          PasswordField(
                            fadePassword: _elementsOpacity == 0,
                            passwordController: passwordController,
                            errorText: passwordError,
                            invalid: passwordInvalid,
                          ),
                          SizedBox(height: 30),
                          LoginButton(
                            elementsOpacity: _elementsOpacity,
                            onTap: () async {
                              UIBlock.block(context);
                              var Authenticated = await AuthService()
                                  .login(accountController.text.toString(), passwordController.text.toString());
                              UIBlock.unblock(context);
                              if (Authenticated['success']) {
                                print(Authenticated);
                                BlocProvider.of<UserCubit>(context).setUser(
                                  UserState(
                                    name: Authenticated['user']['name'],
                                    enumber: Authenticated['user']['enumber'],
                                    email: Authenticated['user']['email'],
                                    avatar: Authenticated['user']['avatar'],
                                    token: Authenticated['user']['token'],
                                    networkEnable: true,
                                  ),
                                );
                                print("Login get token:${Authenticated['user']['token']}");

                                ///登入狀態(進入Cutscene不要再刷一次token)
                                loginRecently = true;
                                ///進入Cutscene
                                setState(() {
                                  loadingBallAppear = true;
                                });
                              } else {
                                ///錯誤訊息
                                print(Authenticated['message']);
                                var error = json.decode(Authenticated['message']);
                                if (error['error'] == null) {
                                  setState(() {
                                    if (error['enumber'] != null) {
                                      accountError = error['enumber'];
                                      accountInvalid = true;
                                      accountController.clear();
                                    } else {
                                      accountInvalid = false;
                                    }
                                    if (error['password'] != null) {
                                      passwordError = error['password'];
                                      passwordInvalid = true;
                                      passwordController.clear();
                                    } else {
                                      passwordInvalid = false;
                                    }
                                  });
                                } else {
                                  setState(() {
                                    accountInvalid = false;
                                    passwordInvalid = false;
                                  });
                                  accountController.clear();
                                  passwordController.clear();
                                  Alert(
                                    context: context,
                                    style: AlertStyles().dangerStyle(context),
                                    image: const ErrorIcon(),
                                    title: tr('auth.login_failed'),
                                    desc: "${error['error']}",
                                    buttons: [
                                      AlertStyles().getReturnLoginButton(context),
                                    ],
                                  ).show();
                                }
                              }
                            },
                            onAnimatinoEnd: () async {
                              await Future.delayed(Duration(milliseconds: 500));
                              setState(() {
                                loadingBallAppear = true;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  getDarkLogo() {
    return Image.asset('assets/img/HwaComLogo_white.png', fit: BoxFit.fill);
    return Row(children: [
      Icon(Ionicons.logo_google, color: Theme
          .of(context)
          .colorScheme
          .primary, size: 50),
      const SizedBox(width: 10),
      Icon(Ionicons.logo_google, color: Theme
          .of(context)
          .colorScheme
          .primary, size: 30),
      const SizedBox(width: 10),
      Icon(Ionicons.logo_linkedin, color: Theme
          .of(context)
          .colorScheme
          .primary, size: 20),
      const SizedBox(width: 10),
      Icon(Ionicons.logo_linkedin, color: Theme
          .of(context)
          .colorScheme
          .primary, size: 20),
      const SizedBox(width: 10),
      Icon(Ionicons.logo_twitter, color: Theme
          .of(context)
          .colorScheme
          .primary, size: 60),
    ]);
  }

  getLightLogo() {
    return Image.asset('assets/img/HwaComLogo_color.png', fit: BoxFit.fill);
  }

}
