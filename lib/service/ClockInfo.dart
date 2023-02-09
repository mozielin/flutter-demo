// ignore_for_file: non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hws_app/models/clock.dart';
import 'package:uuid/uuid.dart';

class ClockInfo {
  final Dio dio = Dio();
  late final Box clockBox = Hive.box('clockBox');

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
          );

          /// 儲存工時資料至 hive 中，使用 auto id 作為 hive 中的 key
          clockBox.put(data['id'].toString(), ClockData);
        }

        print('總共儲存比數：${clockBox.values.length}');
      } else {
        print('404 SyncClock error');
      }
    } catch (e) {
      print('out');
      print(e);
    }
  }

  /// 取得工時資料
  GetClock() async {
    List ClockList = [];
    for (var data in clockBox.values) {
      ClockList.add(data);
    }
    return ClockList;
  }

  /// 同步工時類型
  SyncClockType() async {}

  /// 取得工時類型
  GetClockType() async {}

  /// 同步支援 Case
  SyncSupportCase() async {}

  /// 取得支援 Case
  GetSupportCase() async {}

  /// insert 打卡
  InsertClockIn() async {
    /// 使用 uuid 作為 hive 中的 key
  }

  /// update 打卡
  UpdateClockIn() async {
    /// 使用 uuid 作為 hive 中的 key
  }
}
