// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warranty.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WarrantyAdapter extends TypeAdapter<Warranty> {
  @override
  final int typeId = 6;

  @override
  Warranty read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Warranty(
      data: fields[0] == null ? '' : fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Warranty obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WarrantyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
