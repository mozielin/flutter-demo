// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClockAdapter extends TypeAdapter<Clock> {
  @override
  final int typeId = 2;

  @override
  Clock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Clock(
      id: fields[0] == null ? '' : fields[0] as String,
      type: fields[1] == null ? '' : fields[1] as String,
      clock_attribute: fields[2] == null ? '' : fields[2] as String,
      clocking_no: fields[3] == null ? '' : fields[3] as String,
      source_no: fields[4] == null ? '' : fields[4] as String,
      enumber: fields[5] == null ? '' : fields[5] as String,
      bu_code: fields[6] == null ? '' : fields[6] as String,
      dept_code: fields[7] == null ? '' : fields[7] as String,
      project_id: fields[8] == null ? '' : fields[8] as String,
      context: fields[9] == null ? '' : fields[9] as String,
      function_code: fields[10] == null ? '' : fields[10] as String,
      direct_code: fields[11] == null ? '' : fields[11] as String,
      traffic_hours: fields[12] == null ? 0.0 : fields[12] as double,
      worked_hours: fields[13] == null ? 0.0 : fields[13] as double,
      total_hours: fields[14] == null ? 0.0 : fields[14] as double,
      depart_time: fields[15] == null ? '' : fields[15] as String,
      start_time: fields[16] == null ? '' : fields[16] as String,
      end_time: fields[17] == null ? '' : fields[17] as String,
      status: fields[18] == null ? '' : fields[18] as String,
      created_at: fields[19] == null ? '' : fields[19] as String,
      updated_at: fields[20] == null ? '' : fields[20] as String,
      deleted_at: fields[21] == null ? '' : fields[21] as String,
      sales_enumber: fields[22] == null ? '' : fields[22] as String,
      sales_bu_code: fields[23] == null ? '' : fields[23] as String,
      sales_dept_code: fields[24] == null ? '' : fields[24] as String,
      sap_wbs: fields[25] == null ? '' : fields[25] as String,
      order_date: fields[26] == null ? '' : fields[26] as String,
      internal_order: fields[27] == null ? '' : fields[27] as String,
      bpm_number: fields[28] == null ? '' : fields[28] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Clock obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.clock_attribute)
      ..writeByte(3)
      ..write(obj.clocking_no)
      ..writeByte(4)
      ..write(obj.source_no)
      ..writeByte(5)
      ..write(obj.enumber)
      ..writeByte(6)
      ..write(obj.bu_code)
      ..writeByte(7)
      ..write(obj.dept_code)
      ..writeByte(8)
      ..write(obj.project_id)
      ..writeByte(9)
      ..write(obj.context)
      ..writeByte(10)
      ..write(obj.function_code)
      ..writeByte(11)
      ..write(obj.direct_code)
      ..writeByte(12)
      ..write(obj.traffic_hours)
      ..writeByte(13)
      ..write(obj.worked_hours)
      ..writeByte(14)
      ..write(obj.total_hours)
      ..writeByte(15)
      ..write(obj.depart_time)
      ..writeByte(16)
      ..write(obj.start_time)
      ..writeByte(17)
      ..write(obj.end_time)
      ..writeByte(18)
      ..write(obj.status)
      ..writeByte(19)
      ..write(obj.created_at)
      ..writeByte(20)
      ..write(obj.updated_at)
      ..writeByte(21)
      ..write(obj.deleted_at)
      ..writeByte(22)
      ..write(obj.sales_enumber)
      ..writeByte(23)
      ..write(obj.sales_bu_code)
      ..writeByte(24)
      ..write(obj.sales_dept_code)
      ..writeByte(25)
      ..write(obj.sap_wbs)
      ..writeByte(26)
      ..write(obj.order_date)
      ..writeByte(27)
      ..write(obj.internal_order)
      ..writeByte(28)
      ..write(obj.bpm_number);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
