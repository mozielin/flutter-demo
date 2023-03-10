import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'clock_state.dart';

class ClockCubit extends HydratedCubit<ClockState> {
  ClockCubit()
      : super(ClockState(clockType: {}, userCase: {}, monthly: ''));

  final Dio dio = Dio();

  void setClockType(clockType) => emit(ClockState (clockType:clockType, userCase: state.userCase, monthly:state.monthly));
  void setUserCase(userCase) => emit(ClockState (clockType:state.clockType, userCase:userCase, monthly:state.monthly));
  void setMonthly(monthly) => emit(ClockState (clockType:state.clockType, userCase:state.userCase, monthly:monthly));

  void clearClockType() => emit(ClockState(clockType: {}, userCase: {}, monthly: ''));

  @override
  ClockState? fromJson(Map<String, dynamic> json) {
    return ClockState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(ClockState state) {
    return state.toMap();
  }


}
