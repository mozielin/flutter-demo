part of 'case_cubit.dart';

class CaseState {
  Map userCase;

  CaseState({required this.userCase});

  Map<String, dynamic> toMap() {
    return {
      'userCase': userCase
    };
  }

  factory CaseState.fromMap(Map<String, dynamic> map) {
    return CaseState(
        userCase: map['userCase']
    );
  }

  factory CaseState.fromJson(String source) => CaseState.fromMap(json.decode(source));

  String toJson() => json.encode(toMap);
}

