import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:developer' as developer;
import '../../config/setting.dart';
import '../../cubit/user_cubit.dart';
import '../models/toBeSyncClock.dart';
import '../ui/widgets/alert/icons/error_icon.dart';
import '../ui/widgets/alert/styles.dart';

class SyncService{
  final Dio dio = Dio();

  ///上傳local報工資料
  uploadClockData(token) async {
    try{
      Box toBeSyncClockBox = Hive.box('toBeSyncClockBox');
      Box clockBox = Hive.box('clockBox');
      List uploadList = [];

      ///先塞web修改&刪除的資料
      for (var data in clockBox.values) {
        if(data.sync_status == '1' || data.sync_status == '3'){
          uploadList.add(data.toUploadMap());
        }
      }

      print("Web Upload count: ${uploadList.length}");

      print("Upload sort check before: ${uploadList}");

      ///排序刪除在前
      uploadList.sort((b, a) => a['sync_status'].compareTo(b['sync_status']));

      print("Upload sort check after: ${uploadList}");

      ///塞入local資料
      for (var data in toBeSyncClockBox.values) {
        uploadList.add(data.toUploadMap());
      }

      print("Total Upload count: ${uploadList.length}");

      dio.options.headers['Authorization'] = 'Bearer $token';
      Response res = await dio.post(
        '${InitSettings.apiUrl}:443/api/uploadAppClocks',
        data: jsonEncode(uploadList),
      ).timeout(const Duration(seconds: 5));

      if(res.data != null){
        final Box toBeSyncClockBox = Hive.box('toBeSyncClockBox');
        print(res.data);
        for (var data in res.data) {
          print(data);
          var clockData = toBeSyncClockBox.get(data['id']);
          if(clockData != null) {
            if (data['success']) {
              ///依照每筆回傳成功失敗刪除本地資料
              clockData.delete();
            } else {
              ///錯誤加上錯誤訊息跟狀態
              print(jsonDecode(data['message']));
              clockData.status = '1';
              clockData.sync_failed = jsonDecode(data['message']);
              clockData.save();
            }
          }
        }
        return true;
      }else{
        return false;
      }
    }on DioError catch (e) {
      rethrow;
    }on TimeoutException catch (e) {
      rethrow;
    }catch (e) {
      rethrow;
    }
  }

  ///抓月結日期
  Future initMonthlyDate(token) async {
    String data = '';
    try{
      dio.options.headers['Authorization'] = 'Bearer $token';
      Response res = await dio.post(
        '${InitSettings.apiUrl}:443/api/getClockTypeAPI',
        data: {},
      ).timeout(const Duration(seconds: 3));
      data = res.data['monthly'];
      return data;
    }on DioError catch (e) {
      return '';
    }on TimeoutException catch (e) {
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
      ).timeout(const Duration(seconds: 3));
      Map<String, dynamic> data = res.data['type'];
      return data;
    }on DioError catch (e) {
      return {"response_code": 400, "success": false, "data": null};
    }on TimeoutException catch (e) {
      var errorMsg = tr('auth.connection_error');
      return {"response_code": 400, "success": false, "data": null, "message": '{"error":"$errorMsg"}'};
    }
  }

  ///同步User所有Case
  Future initUserCase(token) async {
    try {
      dio.options.headers['Authorization'] = 'Bearer $token';
      Response res = await dio.post(
          '${InitSettings.apiUrl}:443/api/getUserCase',
          data: {}
      ).timeout(const Duration(seconds: 3));
      Map<String, dynamic> data = res.data;
      return data;
    } on DioError catch (e) {
      return {"response_code": 400, "success": false, "data": null};
    }on TimeoutException catch (e) {
      var errorMsg = tr('auth.connection_error');
      return {"response_code": 400, "success": false, "data": null, "message": '{"error":"$errorMsg"}'};
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