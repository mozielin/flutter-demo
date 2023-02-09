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
  //final UserCubit userBloc = UserCubit();
  ///登入
  Future getCaseType() async {
    try {
      Response response = await dio.post(// TODO: URL 放至 env 相關設定
        '${InitSettings.apiUrl}/api/jwt/login',
        data: {},
        queryParameters: {'apikey': 'YOUR_API_KEY'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && response.data != null) {

        String token = response.data['data']['token'];

        ///解JWT Token
        Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
        var array = token.split('.');
        var remainder = array[1].length % 4;
        if (remainder != 0) {
          var addlen = 4 - remainder;
          for(var i = 0; i < addlen; i++){
            array[1] += '=';
          }
        }
        String decoded = stringToBase64Url.decode(array[1]);
        final parsed = jsonDecode(decoded);

        ///判斷JWT時效
        bool isExpired = DateTime.now().isAfter(
          DateTime.fromMillisecondsSinceEpoch(
            parsed['exp'] * 1000,
            isUtc: false,
          ),
        );

        if(!isExpired){
          return {'success':true, 'user':{'name':parsed['name'], 'email':parsed['email'], 'enumber':parsed['enumber'], 'avatar':parsed['avatar'], 'token':parsed['user_token']}, };
        }
        return json.decode(response.data);
      } else {
        return json.decode(response.data);
      }
    } on DioError catch (e) {
      try{
        if(!e.response!.data['success']) return e.response!.data;
      }catch(es){
        var errorMsg = tr('auth.connection_error');
        return {"response_code": 400, "success": false, "data": null, "message": '{"error":"$errorMsg"}'};
      }
    } on TimeoutException catch (e) {
      var errorMsg = tr('auth.connection_error');
      return {"response_code": 400, "success": false, "data": null, "message": '{"error":"$errorMsg"}'};
    }
  }

  ///離線報工時
  Future initTypeSelection(token) async {
    try{
      dio.options.headers['Authorization'] = 'Bearer $token';
      Response res = await dio.post(
        '${InitSettings.apiUrl}:443/api/getClockTypeAPI', // TODO: URL 放至 env 相關設定
        // 'https://uathws.hwacom.com//api/getClocks', // TODO: URL 放至 env 相關設定
        data: {
          'case_no': 'no_case',
          'attr': 6,
          'has_case': 2 //無Case
        },
      );
      Map<String, dynamic> data = res.data;
      return data;
    }on DioError catch (e) {
      print(e);
    }
  }
}