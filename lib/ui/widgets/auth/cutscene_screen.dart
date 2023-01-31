//import 'package:hws_app/ui/widgets/auth/messages_list.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../cubit/user_cubit.dart';
import '../../../service/authenticate/auth.dart';
import '../alert/icons/error_icon.dart';
import '../alert/styles.dart';

class CutsceneScreen extends StatefulWidget {
  const CutsceneScreen({super.key});

  @override
  State<CutsceneScreen> createState() => _CutsceneScreenState();
}

class _CutsceneScreenState extends State<CutsceneScreen> {
  double loadingBallSize = 1;
  AlignmentGeometry _alignment = Alignment.center;
  bool stopScaleAnimtion = false;
  bool showMessages = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 2000), () {
      setState(() {
        _alignment = Alignment.topRight;
        stopScaleAnimtion = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedAlign(
          duration: Duration(milliseconds: 300),
          alignment: _alignment,
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 500),
            tween: Tween(begin: 0, end: loadingBallSize),
            onEnd: () {
              if (!stopScaleAnimtion) {
                setState(() {
                  if (loadingBallSize == 1) {
                    loadingBallSize = 1.5;
                  } else {
                    loadingBallSize = 1;
                  }
                });
              } else {
                Future.delayed(const Duration(milliseconds: 1), () {
                  //透過Provider取得UserCubit狀態
                  var user = BlocProvider
                      .of<UserCubit>(context)
                      .state;
                  if (user.token != '') {
                    AuthService().verifyToken(user.token)
                        .then((res) {
                      if (res['success']) {
                        var token = res['token'];
                        BlocProvider.of<UserCubit>(context).refreshToken(user, token);
                        print("Token refresh : $token");
                        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                      } else {
                        ///Alert token expired return to login
                        Alert(
                          context: context,
                          style: AlertStyles().dangerStyle(context),
                          image: const ErrorIcon(),
                          title: tr('alerts.token_expired_title'),
                          desc: tr('alerts.token_expired_text'),
                          buttons: [
                            AlertStyles().getReturnLoginButton(context),
                          ],
                        ).show();
                        BlocProvider.of<UserCubit>(context).clearUser();
                      }
                    }).onError((error, stackTrace) {
                      print(error);
                    });
                  } else {
                    debugPrint('Token empty');
                  }
                });
              }
            },
            builder: (_, value, __) => Transform.scale(
              scale: value,
              child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: !stopScaleAnimtion
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    shape: BoxShape.circle,
                  ),
                  child: null),
            ),
          ),
        ),
      ],
    );
  }
}
