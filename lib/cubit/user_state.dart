part of 'user_cubit.dart';

class UserState {
  String name;
  String enumber;
  String email;
  String avatar;
  String token;

  UserState({required this.name,required this.email,required this.enumber,required this.avatar,required this.token});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'enumber': enumber,
      'email': email,
      'avatar': avatar,
      'token': token,
    };
  }

  factory UserState.fromMap(Map<String, dynamic> map) {
    return UserState(
      name: map['name'] as String,
      email: map['email'] as String,
      enumber: map['enumber'] as String,
      avatar: map['avatar'] as String,
      token: map['token'] as String,
    );
  }

  factory UserState.fromJson(String source) => UserState.fromMap(json.decode(source));

  String toJson() => json.encode(toMap);
}

