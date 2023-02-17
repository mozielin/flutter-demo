// ignore_for_file: non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hws_app/config/setting.dart';
import 'package:hws_app/models/clock.dart';
import 'package:hws_app/models/dispatch.dart';
import 'package:hws_app/models/supportCase.dart';
import 'package:hws_app/models/toBeSyncClock.dart';
import 'package:hws_app/models/warranty.dart';
import 'package:uuid/uuid.dart';

class ClockInfo {
  final Dio dio = Dio();
  late final Box clockBox = Hive.box('clockBox');
  late final Box supportCaseBox = Hive.box('supportCaseBox');
  late final Box toBeSyncClockBox = Hive.box('toBeSyncClockBox');
  late final Box dispatchBox = Hive.box('dispatchBox');
  late final Box warrantyBox = Hive.box('warrantyBox');

  /// 同步工時資料
  SyncClock(String token, String enumber) async {
    try {
      /// API 抓取工時資料
      dio.options.headers['Authorization'] = 'Bearer $token';
      Response res = await dio.post(
        '${InitSettings.apiUrl}:443/api/getClocks', // TODO: URL 放至 env 相關設定
        data: {
          'enumber': enumber,
          'skip': 0,
          'take': 1000,
          'isNotMonthly': true
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
            case_no:
                (data['project'] != null) ? data['project']['case_no'] : '',
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
      print('error');
      print(e);
    }
  }

  ///檢查工時資料正確
  CheckClock(id, departTime, startTime, endTime, monthly) async {
    bool result = true;
    List hiveClocks = await ClockInfo().GetClock();
    List errorMessages = [];

    /// print("輸入ID:$id");
    /// print("輸入開始:$startTime");
    /// print("輸入結束:$endTime");

    ///檢查開始時間跟結束時間重複
    if(startTime.isAtSameMomentAs(endTime)){
      errorMessages.add(tr('clock.error.same'));
      result = false;
    }

    ///最小時數超過半小時 & startTime不能早於departTime
    if (endTime.difference(startTime).inMinutes < 30 || startTime.isBefore(departTime)){
      errorMessages.add(tr('clock.error.time'));
      result = false;
    }

    ///後續判斷如果有 departTime = startTime
    if(departTime != '') startTime = departTime;

    ///檢查未來時間
    if(startTime.isAfter(DateTime.now()) || endTime.isAfter(DateTime.now())) {
      errorMessages.add(tr('clock.error.future_clock'));
      result = false;
    }

    ///檢查重複報工
    List clocks = hiveClocks.where((element) {
      DateTime sTime = DateTime.parse(element.depart_time == '' ? element.start_time : element.depart_time);
      DateTime eTime = DateTime.parse(element.end_time);
      ///print("資料ID:${element.id}");
      ///print("資料開始:$sTime");
      ///print("資料結束:$eTime");
      return element.id != id && (
          (sTime.isBefore(endTime) && eTime.isAfter(endTime)) ||
          (sTime.isBefore(startTime) && eTime.isAfter(startTime)) ||
          (sTime.isAfter(startTime) && eTime.isBefore(endTime)) ||
          eTime.isAtSameMomentAs(endTime) || sTime.isAtSameMomentAs(startTime)
      );
    }).toList();

    if (clocks.isNotEmpty) {
      errorMessages.add(
        'clock.error.repeat'.tr(
            namedArgs: {
              'startTime': DateFormat('yyyy-MM-dd HH:mm').format(startTime),
              'endTime': DateFormat('yyyy-MM-dd HH:mm').format(endTime)
            }
        )
      );
      result = false;
    }

    ///檢查月結
    if(startTime.isBefore(DateTime.parse(monthly))) {
      errorMessages.clear();
      errorMessages.add(tr('clock.error.monthly'));
      result = false;
    }

    errorMessages.add(tr('clock.error.edit'));
    return {'success':result, 'message':errorMessages};
  }

  /// 同部工時圖片
  SyncClockImage(String token) async {
    for (var data in clockBox.values) {
      try {
        List<String> images = [];
        dio.options.headers['Authorization'] = 'Bearer $token';
        Response res = await dio.post(
          '${InitSettings.apiUrl}:443/api/getClockImages',
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
            case_no: data.case_no,
            images: json.encode(images),
          );

          /// 儲存工時資料至 hive 中，使用 auto id 作為 hive 中的 key
          clockBox.put(data.id, ClockData);
        } else {
          print('404 SyncClockImage error');
        }
      } catch (e) {
        print('error');
        print(e);
      }
    }
    print('Image 總共儲存比數：${clockBox.values.length}');
  }

  /// 取得工時資料
  GetClock() async {
    List ClockList = [];
    for (var data in toBeSyncClockBox.values) {
      ClockList.add(data);
    }
    return ClockList;
  }

  /// 同步支援 Case
  SyncSupportCase(String token) async {
    try {
      dio.options.headers['Authorization'] = 'Bearer $token';
      Response res = await dio
          .post(
            '${InitSettings.apiUrl}:443/api/getUserCase',
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
      print('SyncSupportCase error');
      print(e);
    }
  }

  /// 取得支援 Case
  GetSupportCase() async {
    var caseData = supportCaseBox.get('first');
    Map caseDataMap = jsonDecode(caseData.data);
    return caseDataMap;
  }

  /// insert 工時資料
  InsertClock(Map data) async {
    /// TODO-Ryan:若同步 toBeSyncClock hive 資料至 Web 時，用 id find clock data，若有 find 到則 updata，若無 find 到則 create
    try {
      /// 使用 uuid 作為 hive 中的 key
      if (data['id'] == '') data['id'] = const Uuid().v1();

      ToBeSyncClock ClockData = ToBeSyncClock(
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
        case_no: data['case_no'] ?? '',
        images: data['images'] ?? '[]',
        sync_status: '1',
        clock_type: data['clock_type'].toString() ?? '',
        sale_type: data['sale_type'].toString() ?? '',
      );

      /// 儲存工時資料至 hive 中，使用 auto id 作為 hive 中的 key
      var res = toBeSyncClockBox.put(data['id'].toString(), ClockData);
      print(res);
      print('InsertClock success');
      return true;
    } catch (e) {
      print('InsertClock error');
      print(e);
      return false;
    }
  }

  /// 取得待同步工時資料
  GetToBeSyncClock() async {
    List ClockList = [];
    for (var data in toBeSyncClockBox.values) {
      ClockList.add(data);
    }
    return ClockList;
  }

  /// 同步使用者的客訴派工單
  SyncDispatch(String token, String enumber) async {
    try {
      dio.options.headers['Authorization'] = 'Bearer $token';

      /// TODO: IP 調整
      Response res = await dio.post(
        'http://10.0.2.2:80/api/dispatch/getUserDispatch',
        data: {
          'enumber': enumber,
        },
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 && res.data != null) {
        await dispatchBox.clear();

        Dispatch DispatchData = Dispatch(
          data: json.encode(res.data),
        );

        dispatchBox.put('first', DispatchData);
        print('SyncDispatch success');
      } else {
        print('404 SyncDispatch error');
      }
    } catch (e) {
      print('SyncDispatch error');
      print(e);
    }
  }

  /// 取得使用者的客訴派工單
  GetDispatch() async {
    var dispatchData = dispatchBox.get('first');
    Map dispatchDataMap = jsonDecode(dispatchData.data);
    return dispatchDataMap;
  }

  /// 同步使用者的定保派工單
  SyncWarranty(String token, String enumber) async {
    try {
      dio.options.headers['Authorization'] = 'Bearer $token';

      /// TODO: IP 調整
      Response res = await dio.post(
        'http://10.0.2.2/api/dispatch/getUserWarranty',
        data: {
          'enumber': enumber,
        },
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 && res.data != null) {
        await warrantyBox.clear();

        Warranty WarrantyData = Warranty(
          data: json.encode(res.data),
        );

        warrantyBox.put('first', WarrantyData);
        print('SyncWarranty success');
      } else {
        print('404 SyncWarranty error');
      }
    } catch (e) {
      print('SyncWarranty error');
      print(e);
    }
  }

  /// 取得使用者的定保派工單
  GetWarranty() async {
    var warrantyData = warrantyBox.get('first');
    Map warrantyDataMap = jsonDecode(warrantyData.data);
    return warrantyDataMap;
  }
}
