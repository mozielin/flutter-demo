import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)

class User extends HiveObject {

  @HiveField(0)
  final String enumber;

  @HiveField(1)
  String dept;

  @HiveField(2, defaultValue: '0')
  String name;

  User({
    required this.enumber,
    required this.name,
    required this.dept,
  });
}

