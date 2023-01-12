import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

class AuthService{
  final Dio dio = Dio();
  ///登入
  Future<Map<String, dynamic>> login(String account, String password) async {
    try {
      Response response = await dio.post(// TODO: URL 放至 env 相關設定
        'http://10.0.2.2/api/jwt/login',
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
      return e.response!.data;
    } on TimeoutException catch (e) {
      var errorMsg = tr('auth.connection_error');
      return {"response_code": 400, "success": false, "data": null, "message": '{"error":"$errorMsg"}'};
    }
  }

  ///登出 todo:登出
  Future<Map<String, dynamic>> logout(String accessToken) async {
    try {
      Response response = await dio.get(
        'http://10.0.2.2/api/logout',
        queryParameters: {'apikey': ''},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      return response.data;
    } on DioError catch (e) {
      return e.response!.data;
    }
  }

}