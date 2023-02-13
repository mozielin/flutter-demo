import 'package:hive/hive.dart';

part 'dispatch.g.dart';

@HiveType(typeId: 5)
class Dispatch extends HiveObject {
  @HiveField(0, defaultValue: '')
  String data;

  Dispatch({
    required this.data,
  });
}
