//import 'package:hws_app/ui/widgets/auth/messages_list.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_version_plus/new_version_plus.dart';
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

  String release = "";

  basicStatusCheck(NewVersionPlus newVersion) async {
    final version = await newVersion.getVersionStatus();
    if (version != null) {
      release = version.releaseNotes ?? "";
      setState(() {});
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
  void initState() {
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

    if (simpleBehavior) {
      basicStatusCheck(newVersion);
    }
    // else {
    //   advancedStatusCheck(newVersion);
    // }


    Future.delayed(Duration(milliseconds: 2000), () {
      setState(() {
        _alignment = Alignment.topRight;
        stopScaleAnimtion = true;
      });
    });

    super.initState();
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
              print(Text(release));
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
