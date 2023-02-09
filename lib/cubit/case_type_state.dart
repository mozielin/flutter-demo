part of 'case_type_cubit.dart';

class CaseTypeState {
  String value;

  CaseTypeState({required this.value});

  Map<String, dynamic> toMap() {
    return {
      'value': value
    };
  }

  factory CaseTypeState.fromMap(Map<String, dynamic> map) {
    return CaseTypeState(
      value: map['value'] as String
    );
  }

  factory CaseTypeState.fromJson(String source) => CaseTypeState.fromMap(json.decode(source));

  String toJson() => json.encode(toMap);
}

