import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'case_state.dart';

class CaseCubit extends HydratedCubit<CaseState> {
  CaseCubit()
      : super(CaseState(userCase: {},));

  final Dio dio = Dio();

  void setUserCase(userCase) => emit(CaseState (userCase:userCase));

  void clearUserCase() => emit(CaseState(userCase: {}));

  @override
  CaseState? fromJson(Map<String, dynamic> json) {
    return CaseState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(CaseState state) {
    return state.toMap();
  }
}
