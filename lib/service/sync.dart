import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:developer' as developer;
import '../../config/setting.dart';
import '../../cubit/user_cubit.dart';

class SyncService{
  final Dio dio = Dio();

  ///離線報工時
  Future initTypeSelection(token) async {
    try{
      dio.options.headers['Authorization'] = 'Bearer $token';
      Response res = await dio.post(
        '${InitSettings.apiUrl}:443/api/getClockTypeAPI',
        data: {},
      );
      Map<String, dynamic> data = res.data;
      return data;
    }on DioError catch (e) {
      print(e);
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
      print(e);
    }
  }
}