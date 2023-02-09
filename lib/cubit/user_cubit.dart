import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../config/setting.dart';
import 'dart:developer' as developer;

part 'user_state.dart';

class UserCubit extends HydratedCubit<UserState> {
  UserCubit()
      : super(UserState(name: 'default', email: 'default', enumber: 'default', avatar: 'default', token: 'default', networkEnable: false));

  final Dio dio = Dio();
  @override
  // TODO: implement state

  void setUser(UserState userState) => emit(UserState(
      name: userState.name,
      email: userState.email,
      enumber: userState.enumber,
      avatar: userState.avatar,
      token: userState.token,
      networkEnable: userState.networkEnable
  ));

  void clearUser() => emit(UserState(name: '', email: '', enumber: '', avatar: '', token: '', networkEnable: false));

  void refreshToken(token) => emit(UserState(
      name: state.name,
      email: state.email,
      enumber: state.enumber,
      avatar: state.avatar,
      token: token,
      networkEnable: true));

  void changeAPIStatus(status) {
    emit(UserState(
        name: state.name,
        email: state.email,
        enumber: state.enumber,
        avatar: state.avatar,
        token: state.token,
        networkEnable: status));
  }

  @override
  UserState? fromJson(Map<String, dynamic> json) {
    return UserState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(UserState state) {
    return state.toMap();
  }
}
