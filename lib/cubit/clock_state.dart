part of 'clock_cubit.dart';

class ClockState {
  Map clockType;
  Map userCase;

  ClockState({required this.clockType, required this.userCase});

  Map<String, dynamic> toMap() {
    return {
      'clockType': clockType,
      'userCase' : userCase
    };
  }

  factory ClockState.fromMap(Map<String, dynamic> map) {
    return ClockState(
        clockType: map['clockType'],
        userCase:map['userCase']
    );
  }

  factory ClockState.fromJson(String source) => ClockState.fromMap(json.decode(source));

  String toJson() => json.encode(toMap);
}

