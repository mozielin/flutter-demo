import 'package:hive/hive.dart';

part 'warranty.g.dart';

@HiveType(typeId: 6)
class Warranty extends HiveObject {
  @HiveField(0, defaultValue: '')
  String data;

  Warranty({
    required this.data,
  });
}
