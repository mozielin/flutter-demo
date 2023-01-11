import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hws_app/ui/widgets/auth/account_field.dart';
import 'package:hws_app/ui/widgets/auth/login_button.dart';
import 'package:hws_app/ui/widgets/auth/cutscene_screen.dart';
import 'package:hws_app/ui/widgets/auth/password_field.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:hws_app/service/authenticate/auth.dart';
import '../../../config/theme.dart';
import '../../../cubit/theme_cubit.dart';
import '../../../cubit/user_cubit.dart';

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
  double loadingBallSize = 1;
  late String accountError = '';
  late String passwordError = '';
  late bool accountInvalid = false;
  late bool passwordInvalid = false;
  late ThemeMode mode;

  @override
  void initState() {
    accountController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<UserCubit, UserState>(
        builder: (BuildContext context, UserState user) {
          return BlocBuilder<ThemeCubit, ThemeModeState>(
              builder: (BuildContext context, ThemeModeState state) {
                return Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  resizeToAvoidBottomInset: true,
                  body: SafeArea(
                    bottom: false,
                    child: loadingBallAppear
                        ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30.0),
                        child: CutsceneScreen())
                        : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 70),
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 300),
                            tween: Tween(begin: 1, end: _elementsOpacity),
                            builder: (_, value, __) => Opacity(
                              opacity: value,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ///Logo放這
                                  state.themeMode == ThemeMode.dark
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Ionicons.logo_google, color: Theme.of(context).colorScheme.primary, size: 50),
                                            const SizedBox(width: 10),
                                            Icon(Ionicons.logo_google, color: Theme.of(context).colorScheme.primary, size: 30),
                                            const SizedBox(width: 10),
                                            Icon(Ionicons.logo_linkedin, color: Theme.of(context).colorScheme.primary, size: 20),
                                            const SizedBox(width: 10),
                                            Icon(Ionicons.logo_linkedin, color: Theme.of(context).colorScheme.primary, size: 20),
                                            const SizedBox(width: 10),
                                            Icon(Ionicons.logo_twitter, color: Theme.of(context).colorScheme.primary, size: 60),
                                          ],
                                      )
                                      : Image.asset('assets/img/appbar_logo.png'),
                                  const SizedBox(height: 25),
                                  Text(
                                    "Welcome, Stranger",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                                  ),
                                  Text(
                                    "Sign in to continue",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
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
                                    var Authenticated = await AuthService().login(accountController.text.toString(), passwordController.text.toString());
                                    if(Authenticated['success']){
                                      BlocProvider.of<UserCubit>(context).setUser(
                                        UserState(
                                          name: Authenticated['user']['name'],
                                          enumber: Authenticated['user']['enumber'],
                                          email: Authenticated['user']['email'],
                                          avatar: Authenticated['user']['avatar'],
                                          token: Authenticated['user']['token'],
                                        ),
                                      );
                                      setState(() {
                                        _elementsOpacity = 0;
                                      });
                                    }else{
                                      ///錯誤訊息
                                      print(Authenticated);
                                      var error = json.decode(Authenticated['message']);
                                      if(error['error'] == null){
                                        setState(() {
                                          if(error['enumber'] != null) {
                                            accountError = error['enumber'];
                                            accountInvalid = true;
                                            accountController.clear();
                                          }else{
                                            accountInvalid = false;
                                          }
                                          if(error['password'] != null){
                                            passwordError = error['password'];
                                            passwordInvalid = true;
                                            passwordController.clear();
                                          }else{
                                            passwordInvalid = false;
                                          }
                                        });
                                      }else{
                                        setState(() {
                                          accountInvalid = false;
                                          passwordInvalid = false;
                                        });
                                        accountController.clear();
                                        passwordController.clear();
                                        ArtSweetAlert.show(
                                            context: context,
                                            artDialogArgs: ArtDialogArgs(
                                                type: ArtSweetAlertType.danger,
                                                title: tr('auth.login_failed'),
                                                text: "${error['error']}"
                                            )
                                        );
                                      }
                                    }
                                  },
                                  onAnimatinoEnd: () async {
                                    print(user.token);
                                    await Future.delayed(
                                        Duration(milliseconds: 500));
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
        }
    );
  }
}