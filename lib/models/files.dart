import 'package:hive/hive.dart';

part 'files.g.dart';

@HiveType(typeId: 7)

class Files extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String clockId;

  @HiveField(2)
  String path;

  Files({
    required this.id,
    required this.clockId,
    required this.path,
  });
}

