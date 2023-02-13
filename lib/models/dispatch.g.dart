// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatch.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DispatchAdapter extends TypeAdapter<Dispatch> {
  @override
  final int typeId = 5;

  @override
  Dispatch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dispatch(
      data: fields[0] == null ? '' : fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Dispatch obj) {
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
      other is DispatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
