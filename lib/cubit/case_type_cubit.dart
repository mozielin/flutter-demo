import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'case_type_state.dart';

class CaseTypeCubit extends HydratedCubit<CaseTypeState> {
  CaseTypeCubit()
      : super(CaseTypeState(value: '',));

  final Dio dio = Dio();
  @override
  // TODO: implement state

  void setCaseType(CaseTypeState typeState) => emit(typeState);

  void clearCaseType() => emit(CaseTypeState(value: ''));

  @override
  CaseTypeState? fromJson(Map<String, dynamic> json) {
    return CaseTypeState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(CaseTypeState state) {
    return state.toMap();
  }
}
