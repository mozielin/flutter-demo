import 'package:dio/dio.dart' as api;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hws_app/config/theme.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../cubit/clock_cubit.dart';
import '../../../cubit/user_cubit.dart';
import '../../../service/ClockInfo.dart';
import '../../../service/authenticate/auth.dart';
import '../../../service/sync.dart';
import '../alert/icons/error_icon.dart';
import '../alert/styles.dart';
import 'dart:async';
import 'package:ionicons/ionicons.dart';
import 'dart:developer' as developer;

import 'animation_egg.dart';

class CutsceneScreen extends StatefulWidget {
  const CutsceneScreen({super.key, required bool loginRecently});

  @override
  State<CutsceneScreen> createState() => _CutsceneScreenState();
}

class _CutsceneScreenState extends State<CutsceneScreen> {
  bool _stopScaleAnimation = false;
  bool _apiEnable = false;
  String _infoTitle = tr('cutscene.info_default_title');
  String _infoText = tr('cutscene.info_default_text');
  final api.Dio dio = api.Dio();
  Stream? _initStreamData;
  bool _syncStatusVisible = false;

  setStopScaleAnimation() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      ///進入首頁
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void initState() {
    super.initState();

    ///嘗試驗證token判斷是否可以連到API Server
    developer.log('Cutscene...');
    _infoText = tr('cutscene.info_authenticate_text');
    var user = BlocProvider.of<UserCubit>(context).state;
    if (user.token != '') {
      developer.log("Token verify: ${user.token}");
      AuthService().verifyToken(user.token).then((res) {
        if (res['success']) {
          _apiEnable = true;
          var token = res['token'];
          BlocProvider.of<UserCubit>(context).refreshToken(token);
          developer.log("Token refresh: $token");

          //TODO:上傳未同步報工紀錄接在這
          ///同步資料API
          _infoText = tr('cutscene.info_default_text');
          _initStreamData = (() async* {
            var user = BlocProvider.of<UserCubit>(context).state;
            String message;
            bool status;

            ///同步工時資料
            yield await ClockInfo().SyncClock(user.token, user.enumber).then((result){
              message = tr('cutscene.sync.clock');
              if(result) {
                developer.log("syncClock: Done");
                status = true;
              } else {
                developer.log("syncClock: Failed");
                status = false;
              }
              return {'message':message, 'status':status};
            });

            ///同步工時附檔資料(非同步因為這支會卡太久影響UX)
            ClockInfo().SyncClockImage(user.token).then((result){
              message = tr('cutscene.sync.clock_file');
              if(result) {
                developer.log("syncClockFile: Done");
                status = true;
              } else {
                developer.log("syncClockFile: Failed");
                status = false;
              }
            });

            ///同步工時類別
            yield await SyncService().initTypeSelection(user.token).then((resultInitType){
              message = tr('cutscene.sync.clock_type');
              if(resultInitType['success'] == false) {
                developer.log("initTypeSelection: Failed");
                status = false;
              } else {
                developer.log("initTypeSelection: Done");
                BlocProvider.of<ClockCubit>(context).setClockType(resultInitType);
                status = true;
              }
              return {'message':message, 'status':status};
            });

            ///同步CRM派工資料
            yield await ClockInfo().SyncDispatch(user.token, user.enumber).then((result){
              message = tr('cutscene.sync.dispatch');
              if(result) {
                developer.log("initDispatch: Done");
                status = true;
              } else {
                developer.log("initDispatch: Failed");
                status = false;
              }
              return {'message':message, 'status':status};
            });

            ///同步CRM定保資料
            yield await ClockInfo().SyncWarranty(user.token, user.enumber).then((result){
              message = tr('cutscene.sync.warranty');
              if(result) {
                developer.log("initWarranty: Done");
                status = true;
              } else {
                developer.log("initWarranty: Failed");
                status = false;
              }
              return {'message':message, 'status':status};
            });

            ///同步工時月結日期
            yield await SyncService().initMonthlyDate(user.token).then((monthly){
              message = tr('cutscene.sync.monthly');
              if(monthly == '') {
                developer.log("initMonthlyDate: Failed");
                status = false;
              } else {
                developer.log("initMonthlyDate: Done");
                BlocProvider.of<ClockCubit>(context).setMonthly(monthly);
                status = true;
              }
              return {'message':message, 'status':status};
            });

            ///同步用戶專案資料
            yield await SyncService().initUserCase(user.token).then((resultUserCase){
              message = tr('clock.sync.case');
              if(resultUserCase['success'] == false) {
                developer.log("initUserCase: Failed");
                status = false;
              } else {
                developer.log("initUserCase: Done");
                BlocProvider.of<ClockCubit>(context).setUserCase(resultUserCase);
                status = true;
              }
              return {'message':message, 'status':status};
            });

          })();

        } else {
          if (res['response_code'] == 419){
            _logoutUser();
          }else{
            BlocProvider.of<UserCubit>(context).changeAPIStatus(false);
            developer.log('Failed to fetch api', error: res['message']);
            _infoTitle = tr('cutscene.sync.pass');
            _infoText = tr('cutscene.apiDisable_text');
            ///進入首頁
            setStopScaleAnimation();
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimationEgg(stopScaleAnimation:_stopScaleAnimation, apiEnable:_apiEnable),
          const SizedBox(height: 16),
          AnimatedOpacity(
            opacity: _syncStatusVisible ? 0.0 : 1.0,
            duration: const Duration(seconds: 1),
            child: StreamBuilder(
                stream: _initStreamData,
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  if (snapshot.hasError) {
                    print('Error: ${snapshot}');
                    return Text('Error: ${snapshot.error}');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      _syncStatusVisible = false;
                      break;
                  //return Text('没有Stream');
                    case ConnectionState.waiting:
                      break;
                  //return Text('等待数据...');
                    case ConnectionState.active:
                      if(snapshot.hasData) _syncStatusVisible = true;
                      break;
                    case ConnectionState.done:
                      _infoTitle = tr('cutscene.finish_title');
                      _infoText = tr('cutscene.finish_text');
                      _syncStatusVisible = false;
                      setStopScaleAnimation();
                      break;
                  }// unreachable
                  return Column(
                    children: [
                      Text(
                        _infoTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _syncStatusVisible ?
                          getStreamResult(snapshot.data) :
                          Text(
                            _infoText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ///跳過同步
                      // TextButton.icon(
                      //   onPressed: () async {
                      //     ///進入首頁
                      //     setStopScaleAnimation();
                      //   },
                      //   icon: const Icon(Ionicons.earth_outline,
                      //       color: MetronicTheme.primary),
                      //   label:const Text(
                      //     'skip',
                      //     textAlign: TextAlign.center,
                      //     overflow: TextOverflow.ellipsis,
                      //     style: TextStyle(color: MetronicTheme.primary, fontSize: 16, fontWeight: FontWeight.bold),
                      //   ),
                      //   style: TextButton.styleFrom(
                      //     foregroundColor: Colors.red,
                      //   ),
                      // ),
                    ],
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  getStreamResult(data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${data['message']} ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Icon(
          data['status'] ? Ionicons.checkmark_outline : Ionicons.close_outline,
          color: data['status'] ? MetronicTheme.success : MetronicTheme.danger,
        ),
      ],
    );
  }
}
