// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';

part 'supportCase.g.dart';

@HiveType(typeId: 3)
class SupportCase extends HiveObject {
  @HiveField(0, defaultValue: '')
  String data;

  SupportCase({
    required this.data,
  });
}
