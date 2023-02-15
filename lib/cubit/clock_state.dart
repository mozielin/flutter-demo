part of 'clock_cubit.dart';

class ClockState {
  Map clockType;
  Map userCase;
  String monthly;

  ClockState({required this.clockType, required this.userCase, required this.monthly});

  Map<String, dynamic> toMap() {
    return {
      'clockType': clockType,
      'userCase' : userCase,
      'monthly' : monthly
    };
  }

  factory ClockState.fromMap(Map<String, dynamic> map) {
    return ClockState(
        clockType: map['clockType'],
        userCase:map['userCase'],
        monthly:map['monthly']
    );
  }

  factory ClockState.fromJson(String source) => ClockState.fromMap(json.decode(source));

  String toJson() => json.encode(toMap);
}

