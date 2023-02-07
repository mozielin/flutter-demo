import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:developer' as developer;
import '../../config/setting.dart';
import '../../cubit/user_cubit.dart';

class AuthService{
  final Dio dio = Dio();
  //final UserCubit userBloc = UserCubit();
  ///登入
  Future login(String account, String password) async {
    try {
      Response response = await dio.post(// TODO: URL 放至 env 相關設定
        '${InitSettings.apiUrl}/api/jwt/login',
        data: {
          'enumber': account,
          'password': password,
          'exp': '7400',
        },
        queryParameters: {'apikey': 'YOUR_API_KEY'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && response.data != null) {

        String token = response.data['data']['token'];

        ///解JWT Token
        Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
        var array = token.split('.');
        var remainder = array[1].length % 4;
        var addlen = 4 - remainder;
        for(var i = 0; i < addlen; i++){
          array[1] += '=';
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

  ///登出 todo:登出
  Future<bool> logout() async {
    try {
      //print(userBloc.state);
      return true;
    } on DioError catch (e) {
      return true;
    }
  }

  ///驗證token並回傳新token
  Future<Map<String, dynamic>> verifyToken(String token) async {
    String errormsg = '';
    try {
      dio.options.headers['Authorization'] = 'Bearer $token';
      Response response = await dio.post(
        '${InitSettings.apiUrl}/api/refresh/token'
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && response.data != null) {
        String token = response.data['token'];
        developer.log('User-token: $token');
        ///TODO:成功刷新token觸發同步事件並上傳工時
        return {'success':true, 'token':token};
      } else {
        return json.decode(response.data);
      }

    } on DioError catch (e) {
      try{
        var statusCode = e.response!.statusCode;
        if (statusCode == 302){
          ///token過期清空使用者資訊並倒回登入
          developer.log('Token-Expired');
          developer.log('Clear User data and Redirect to Login');
        }else{
          ///直接進去(離線版)
          errormsg = 'Cannot Verify Token code:$statusCode';
          developer.log('Cannot Verify Token and Login Local');
          developer.log('${e.response!.statusMessage}');
        }
      }catch(es){
        ///直接進去(離線版)
        errormsg = 'Undefined Dio Error';
        developer.log('Cannot Verify Token and Login Local');
      }
      return {"response_code": 400, "success": false, "data": null, "message": '{"error":"$errormsg"}'};
    } on TimeoutException catch (e) {
      ///直接進去(離線版)
      var errorMsg = tr('auth.connection_error');
      return {"response_code": 400, "success": false, "data": null, "message": '{"error":"$errorMsg"}'};
    }
  }
}