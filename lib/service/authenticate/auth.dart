import 'package:hws_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
class AuthService{
  final Dio dio = Dio();

  //把firebase物件轉成LoginUser
  User? _baseUser(User? user){
    return user != null ? User(enumber: user.enumber, name: user.name, dept: user.dept): null;
    //return LoginUser(uid: user?.uid);
  }
  // 當登入狀態變動時Stream
  // Stream<User?> get user{
  //   //debugPrint("SG");
  //   return _auth.userChanges().map<User?>(_baseUser);
  // }

  // // 把firebase物件轉成LoginUser
  // LoginUser? _userFromFirebaseUser(User? user){
  //   return user != null ? LoginUser(uid: user.uid): null;
  // }
  // // 當登入狀態變動時Stream
  // Stream<LoginUser?> get user{
  //   return _auth.userChanges().map<LoginUser?>(_userFromFirebaseUser);
  // }

  //登入
  Future<Response> login(String enumber, String password) async {
    try {
      Response response = await dio.post(
        'http://10.0.0.2/api/jwt/login',
        data: {
          'enumber': enumber,
          'password': password
        },
        queryParameters: {'apikey': 'YOUR_API_KEY'},
      );
      //returns the successful user data json object
      return response.data;
    } on DioError catch (e) {
      //returns the error object if any
      return e.response!.data;
    }
  }

  //登出
  Future<Response> logout(String accessToken) async {
    try {
      Response response = await dio.get(
        'https://10.0.0.2/api/logout',
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