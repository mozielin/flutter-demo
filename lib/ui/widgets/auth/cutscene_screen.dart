//import 'package:hws_app/ui/widgets/auth/messages_list.dart';

import 'package:dio/dio.dart' as api;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hws_app/config/theme.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../config/setting.dart';
import '../../../cubit/user_cubit.dart';
import '../../../service/authenticate/auth.dart';
import '../alert/icons/error_icon.dart';
import '../alert/styles.dart';

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class CutsceneScreen extends StatefulWidget {
  const CutsceneScreen({super.key});

  @override
  State<CutsceneScreen> createState() => _CutsceneScreenState();
}

class _CutsceneScreenState extends State<CutsceneScreen> {
  double loadingBallSize = 1;
  AlignmentGeometry _alignment = Alignment.center;
  bool stopScaleAnimtion = false;
  bool _apiEnable = false;
  bool showMessages = true;

  String release = "";

  final api.Dio dio = api.Dio();

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
    super.initState();
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

    ///嘗試驗證token判斷是否可以連到API Server
    developer.log('Cutscene...');
    var user = BlocProvider.of<UserCubit>(context).state;
    developer.log('User-Token:${user.token}');
    if (user.token != '') {
      AuthService().verifyToken(user.token).then((res) {
        if (res['success']) {
          _apiEnable = true;
          var token = res['token'];
          BlocProvider.of<UserCubit>(context).refreshToken(token);
          developer.log("Token refresh: $token");
        } else {
          if (res['response_code'] == 419){
            _logoutUser();
          }else{
            BlocProvider.of<UserCubit>(context).changeAPIStatus(false);
            developer.log('Failed to fetch api', error: res['message']);

            //TODO:同步資料API可以寫在這、上傳未同步報工紀錄也接在這
            Future.delayed(Duration(milliseconds: 3000), () {
              setState(() {
                stopScaleAnimtion = true;
              });
            });
          }
        }
      }).onError((error, stackTrace) {
        ///Alert token expired return to login
        _logoutUser();
      });
    } else {
      developer.log('Token empty');
    }
  }

  _logoutUser(){
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedAlign(
            duration: Duration(milliseconds: 300),
            alignment: Alignment.center,
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
                  if(_apiEnable){
                    developer.log('ApiEnable...');
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                  }else{
                    developer.log('ApiDisable...');
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                  }
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
          SizedBox(height: 16),
          Text(
            'Connecting API Server...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(BlocProvider.of<UserCubit>(context).state.networkEnable ? 'Enabled' : 'Disabled', style: TextStyle(color: BlocProvider.of<UserCubit>(context).state.networkEnable ? MetronicTheme.success : MetronicTheme.danger, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ));
  }
}
