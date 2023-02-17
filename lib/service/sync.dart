import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:developer' as developer;
import '../../config/setting.dart';
import '../../cubit/user_cubit.dart';
import '../ui/widgets/alert/icons/error_icon.dart';
import '../ui/widgets/alert/styles.dart';

class SyncService{
  final Dio dio = Dio();

  ///抓月結日期
  Future initMonthlyDate(token) async {
    String data = '';
    try{
      dio.options.headers['Authorization'] = 'Bearer $token';
      Response res = await dio.post(
        '${InitSettings.apiUrl}:443/api/getClockTypeAPI',
        data: {},
      );
      data = res.data['monthly'];
      return data;
    }on DioError catch (e) {
      return '';
    }
  }

  ///離線報工時
  Future initTypeSelection(token) async {
    try{
      dio.options.headers['Authorization'] = 'Bearer $token';
      Response res = await dio.post(
        '${InitSettings.apiUrl}:443/api/getClockTypeAPI',
        data: {},
      );
      Map<String, dynamic> data = res.data['type'];
      return data;
    }on DioError catch (e) {
      return {"response_code": 400, "success": false, "data": null};
    }
  }

  ///同步User所有Case
  Future initUserCase(token) async {
    try {
      dio.options.headers['Authorization'] = 'Bearer $token';
      Response res = await dio.post(
          '${InitSettings.apiUrl}:443/api/getUserCase',
          data: {}
      );
      Map<String, dynamic> data = res.data;
      return data;
    } on DioError catch (e) {
      return {"response_code": 400, "success": false, "data": null};
    }
  }

  //錯誤訊息alert
  // errorAlert(msg) {
  //   return Alert(
  //     context: context,
  //     style: AlertStyles().dangerStyle(context),
  //     image: const ErrorIcon(),
  //     title: tr('alerts.confirm_error'),
  //     desc: msg,
  //     buttons: [
  //       AlertStyles().getCancelButton(context),
  //     ],
  //   ).show();
  // }
}