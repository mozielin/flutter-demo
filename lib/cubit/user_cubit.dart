import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'user_state.dart';

class UserCubit extends HydratedCubit<UserState> {
  UserCubit()
      : super(UserState(name: 'default', email: 'default', enumber: 'default', avatar: 'default', token: 'default'));

  void setUser(UserState userState) => emit(UserState(
      name: userState.name,
      email: userState.email,
      enumber: userState.enumber,
      avatar: userState.avatar,
      token: userState.token));

  void clearUser() => emit(UserState(name: '', email: '', enumber: '', avatar: '', token: ''));

  void refreshToken(UserState userState, token) => emit(UserState(
      name: userState.name,
      email: userState.email,
      enumber: userState.enumber,
      avatar: userState.avatar,
      token: token));

  @override
  UserState? fromJson(Map<String, dynamic> json) {
    return UserState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(UserState state) {
    return state.toMap();
  }
}
