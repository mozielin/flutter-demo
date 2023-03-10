// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:hive/hive.dart';

part 'clock.g.dart';

@HiveType(typeId: 2)
class Clock extends HiveObject {
  @HiveField(0, defaultValue: '')
  String id;
  @HiveField(1, defaultValue: '')
  String type;
  @HiveField(2, defaultValue: '')
  String clock_attribute;
  @HiveField(3, defaultValue: '')
  String clocking_no;
  @HiveField(4, defaultValue: '')
  String source_no;
  @HiveField(5, defaultValue: '')
  String enumber;
  @HiveField(6, defaultValue: '')
  String bu_code;
  @HiveField(7, defaultValue: '')
  String dept_code;
  @HiveField(8, defaultValue: '')
  String project_id;
  @HiveField(9, defaultValue: '')
  String context;
  @HiveField(10, defaultValue: '')
  String function_code;
  @HiveField(11, defaultValue: '')
  String direct_code;
  @HiveField(12, defaultValue: 0.0)
  double traffic_hours;
  @HiveField(13, defaultValue: 0.0)
  double worked_hours;
  @HiveField(14, defaultValue: 0.0)
  double total_hours;
  @HiveField(15, defaultValue: '')
  String depart_time;
  @HiveField(16, defaultValue: '')
  String start_time;
  @HiveField(17, defaultValue: '')
  String end_time;
  @HiveField(18, defaultValue: '')
  String status;
  @HiveField(19, defaultValue: '')
  String created_at;
  @HiveField(20, defaultValue: '')
  String updated_at;
  @HiveField(21, defaultValue: '')
  String deleted_at;
  @HiveField(22, defaultValue: '')
  String sales_enumber;
  @HiveField(23, defaultValue: '')
  String sales_bu_code;
  @HiveField(24, defaultValue: '')
  String sales_dept_code;
  @HiveField(25, defaultValue: '')
  String sap_wbs;
  @HiveField(26, defaultValue: '')
  String order_date;
  @HiveField(27, defaultValue: '')
  String internal_order;
  @HiveField(28, defaultValue: '')
  String bpm_number;
  @HiveField(29, defaultValue: '')
  String case_no;
  @HiveField(30, defaultValue: '')
  String images;
  @HiveField(31, defaultValue: '')
  String sync_status;
  @HiveField(32, defaultValue: '')
  String clock_type;
  @HiveField(33, defaultValue: '')
  String sale_type;
  @HiveField(34, defaultValue: '')
  String sync_failed;
  @HiveField(35, defaultValue: '')
  String is_verify;

  Clock({
    required this.id,
    required this.type,
    required this.clock_attribute,
    required this.clocking_no,
    required this.source_no,
    required this.enumber,
    required this.bu_code,
    required this.dept_code,
    required this.project_id,
    required this.context,
    required this.function_code,
    required this.direct_code,
    required this.traffic_hours,
    required this.worked_hours,
    required this.total_hours,
    required this.depart_time,
    required this.start_time,
    required this.end_time,
    required this.status,
    required this.created_at,
    required this.updated_at,
    required this.deleted_at,
    required this.sales_enumber,
    required this.sales_bu_code,
    required this.sales_dept_code,
    required this.sap_wbs,
    required this.order_date,
    required this.internal_order,
    required this.bpm_number,
    required this.case_no,
    required this.images,
    required this.sync_status,
    required this.clock_type,
    required this.sale_type,
    required this.sync_failed,
    required this.is_verify,
  });

  Map<String, dynamic> toUploadMap() {
    return {
      'id' : id,
      'type' : type,
      'clock_attribute':clock_attribute,
      'project_id':project_id,
      'context':context,
      'traffic_hours':traffic_hours,
      'worked_hours':worked_hours,
      'total_hours':total_hours,
      'departTime':depart_time,
      'startTime':start_time,
      'endTime':end_time,
      'draft':status,
      'internal_order':internal_order,
      'case_number':case_no,
      'sync_status':sync_status,
      'clock_type':clock_type,
      'sale_type':sale_type,
    };
  }

  String toJson() => json.encode(toUploadMap);
}
