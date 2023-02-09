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
import '../../../cubit/case_type_cubit.dart';
import '../../../cubit/user_cubit.dart';
import '../../../service/authenticate/auth.dart';
import '../../../service/sync.dart';
import '../alert/icons/error_icon.dart';
import '../alert/styles.dart';

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class CutsceneScreen extends StatefulWidget {
  const CutsceneScreen({super.key, required bool loginRecently});

  @override
  State<CutsceneScreen> createState() => _CutsceneScreenState();
}

class _CutsceneScreenState extends State<CutsceneScreen> {
  double _loadingBallSize = 1;
  bool _stopScaleAnimtion = false;
  bool _apiEnable = false;
  String _infoTitle = tr('cutscene.info_default_title');
  String _infoText = tr('cutscene.info_default_text');
  final api.Dio dio = api.Dio();

  @override
  void initState() {
    super.initState();

    ///嘗試驗證token判斷是否可以連到API Server
    developer.log('Cutscene...');
    var user = BlocProvider.of<UserCubit>(context).state;
    if (user.token != '') {
      developer.log("Token verify: ${user.token}");
      ///TODO:刷新的token沒存到導致一直驗證不過被登出
      AuthService().verifyToken(user.token).then((res) {
        if (res['success']) {
          _apiEnable = true;
          var token = res['token'];
          BlocProvider.of<UserCubit>(context).refreshToken(token);
          developer.log("Token refresh: $token");

          //TODO:同步資料API可以寫在這、上傳未同步報工紀錄也接在這

          SyncService().initTypeSelection(user.token).then((res){
            _infoTitle = tr('cutscene.clock_type_title');
            _infoText = tr('cutscene.clock_type_text');
            print(res);
            BlocProvider.of<CaseTypeCubit>(context).setCaseType(CaseTypeState(value: "$res"));
            print(res['6']['child']);
          });

          Future.delayed(const Duration(milliseconds: 1500), () {
            _infoTitle = tr('cutscene.finish_title');
            _infoText = tr('cutscene.finish_text');
          });

          Future.delayed(const Duration(milliseconds: 5000), () {
            setState(() {
              ///最後判斷是否結束動畫進入首頁
              _stopScaleAnimtion = true;
            });
          });

        } else {
          if (res['response_code'] == 419){
            _logoutUser();
          }else{
            BlocProvider.of<UserCubit>(context).changeAPIStatus(false);
            developer.log('Failed to fetch api', error: res['message']);
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
              tween: Tween(begin: 0, end: _loadingBallSize),
              onEnd: () {
                if (!_stopScaleAnimtion) {
                  setState(() {
                    if (_loadingBallSize == 1) {
                      _loadingBallSize = 1.5;
                    } else {
                      _loadingBallSize = 1;
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
                      color: !_stopScaleAnimtion
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
            _infoTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            _infoText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(BlocProvider.of<UserCubit>(context).state.networkEnable ? 'Enabled' : 'Disabled', style: TextStyle(color: BlocProvider.of<UserCubit>(context).state.networkEnable ? MetronicTheme.success : MetronicTheme.danger, fontSize: 16, fontWeight: FontWeight.bold)),
          TextButton(onPressed: (){
            setState(() {
              ///最後判斷是否結束動畫進入首頁
              _stopScaleAnimtion = true;
            });
          }, child:Text('Skip', style: TextStyle(color: MetronicTheme.success, fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ));
  }
}
