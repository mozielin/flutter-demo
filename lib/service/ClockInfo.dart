// ignore_for_file: non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hws_app/config/setting.dart';
import 'package:hws_app/models/clock.dart';
import 'package:hws_app/models/supportCase.dart';
import 'package:uuid/uuid.dart';

class ClockInfo {
  final Dio dio = Dio();
  late final Box clockBox = Hive.box('clockBox');
  late final Box supportCaseBox = Hive.box('supportCaseBox');

  /// 同步工時資料
  SyncClock(token) async {
    try {
      /// API 抓取工時資料
      dio.options.headers['Authorization'] = 'Bearer $token';
      Response res = await dio.post(
        'http://192.168.12.68:443/api/getClocks', // TODO: URL 放至 env 相關設定
        data: {
          'enumber': 'HW-M54',
          'skip': 0,
          'take': 1000,
        },
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 && res.data != null) {
        /// 清除所有工時資料
        await clockBox.clear();

        for (var data in res.data['clocks']) {
          Clock ClockData = Clock(
            id: data['id'].toString(),
            type: data['type'].toString(),
            clock_attribute: data['clock_attribute'].toString(),
            clocking_no: data['clocking_no'],
            source_no: data['source_no'] ?? '',
            enumber: data['enumber'],
            bu_code: data['bu_code'],
            dept_code: data['dept_code'],
            project_id: data['project_id'] ?? '',
            context: data['context'],
            function_code: data['function_code'],
            direct_code: data['direct_code'],
            traffic_hours: data['traffic_hours'].toDouble(),
            worked_hours: data['worked_hours'].toDouble(),
            total_hours: data['total_hours'].toDouble(),
            depart_time: data['depart_time'],
            start_time: data['start_time'],
            end_time: data['end_time'],
            status: data['status'].toString(),
            created_at: data['created_at'],
            updated_at: data['updated_at'],
            deleted_at: data['deleted_at'] ?? '',
            sales_enumber: data['sales_enumber'],
            sales_bu_code: data['sales_bu_code'],
            sales_dept_code: data['sales_dept_code'],
            sap_wbs: data['sap_wbs'] ?? '',
            order_date: data['order_date'] ?? '',
            internal_order: data['internal_order'] ?? '',
            bpm_number: data['bpm_number'] ?? '',
            images: '[]',
          );

          /// 儲存工時資料至 hive 中，使用 auto id 作為 hive 中的 key
          clockBox.put(data['id'].toString(), ClockData);
        }

        print('Clock 總共儲存比數：${clockBox.values.length}');
      } else {
        print('404 SyncClock error');
      }
    } catch (e) {
      print('out');
      print(e);
    }
  }

  /// 同部工時圖片
  SyncClockImage(token) async {
    for (var data in clockBox.values) {
      try {
        List<String> images = [];
        dio.options.headers['Authorization'] = 'Bearer $token';
        Response res = await dio.post(
          'http://192.168.12.68:443/api/getClockImages',
          data: {'clock_id': data.id},
        ).timeout(const Duration(seconds: 5));

        if (res.statusCode == 200 && res.data != null) {
          for (var each in res.data['images']) {
            images.add(each['base64_path'].split('base64,')[1]);
          }

          Clock ClockData = Clock(
            id: data.id,
            type: data.type,
            clock_attribute: data.clock_attribute,
            clocking_no: data.clocking_no,
            source_no: data.source_no,
            enumber: data.enumber,
            bu_code: data.bu_code,
            dept_code: data.dept_code,
            project_id: data.project_id,
            context: data.context,
            function_code: data.function_code,
            direct_code: data.direct_code,
            traffic_hours: data.traffic_hours,
            worked_hours: data.worked_hours,
            total_hours: data.total_hours,
            depart_time: data.depart_time,
            start_time: data.start_time,
            end_time: data.end_time,
            status: data.status,
            created_at: data.created_at,
            updated_at: data.updated_at,
            deleted_at: data.deleted_at,
            sales_enumber: data.sales_enumber,
            sales_bu_code: data.sales_bu_code,
            sales_dept_code: data.sales_dept_code,
            sap_wbs: data.sap_wbs,
            order_date: data.order_date,
            internal_order: data.internal_order,
            bpm_number: data.bpm_number,
            images: json.encode(images),
          );

          /// 儲存工時資料至 hive 中，使用 auto id 作為 hive 中的 key
          clockBox.put(data.id, ClockData);
        } else {
          print('404 SyncClockImage error');
        }
      } catch (e) {
        print('out');
        print(e);
      }
    }
    print('Image 總共儲存比數：${clockBox.values.length}');
  }

  /// 取得工時資料
  GetClock() async {
    List ClockList = [];
    for (var data in clockBox.values) {
      ClockList.add(data);
    }
    return ClockList;
  }

  /// 同步支援 Case
  SyncSupportCase(token) async {
    try {
      List<String> images = [];
      dio.options.headers['Authorization'] = 'Bearer $token';
      Response res = await dio
          .post(
            'http://192.168.12.68:443/api/getUserCase',
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 && res.data != null) {
        await supportCaseBox.clear();

        SupportCase SupportCaseData = SupportCase(
          data: json.encode(res.data),
        );

        supportCaseBox.put('first', SupportCaseData);
        print('SyncSupportCase success');
      } else {
        print('404 SyncSupportCase error');
      }
    } catch (e) {
      print('SyncSupportCase out');
      print(e);
    }
  }

  /// 取得支援 Case
  GetSupportCase() async {
    var caseData = supportCaseBox.get('first');
    Map caseDataMap = jsonDecode(caseData.data);
    return caseDataMap;
  }

  /// insert 打卡
  InsertClockIn() async {
    /// 使用 uuid 作為 hive 中的 key
  }

  /// update 打卡
  UpdateClockIn() async {
    /// 使用當前工時的 id 作為 hive 中的 key
  }
}
