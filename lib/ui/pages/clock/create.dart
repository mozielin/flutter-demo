import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:hws_app/ui/widgets/alert/alert_icons.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../config/theme.dart';
import '../../../cubit/theme_cubit.dart';
import '../../../cubit/user_cubit.dart';
import '../../../service/ImageController.dart';
import '../../widgets/alert/icons/error_icon.dart';
import '../../widgets/alert/styles.dart';
import '../../widgets/clock/clock_child_type.dart';
import '../../widgets/clock/clock_type.dart';
import '../../widgets/common/main_appbar.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart' as api;

import '../file_demo.dart';

enum SingingCharacter { project, office, day_off }

class CreateClock extends StatefulWidget  {
  @override
  State<CreateClock> createState() => _CreateClockState();
}

class _CreateClockState extends State<CreateClock> {
  final api.Dio dio = api.Dio();
  SingingCharacter? _character = SingingCharacter.project;
  final _depart = TextEditingController(); //出發時間
  final _start = TextEditingController(); //開始時間
  final _end = TextEditingController(); //結束時間
  final _departHour = TextEditingController(); //通勤時數
  final _totalHours = TextEditingController(); //總時數
  final _worksHours = TextEditingController(); //工作時數
  final _clock_context = TextEditingController(); //工作內容
  late Map allType = Map(); //屬性、主、子類別
  var typeBoxVisible = 1.0; //主子類別透明度
  bool typeBoxSet = true; //主子類別調完透明度調整空間
  int attr_id = 6; //屬性id
  var parent_id;
  bool type_init_value = true; //是否為主類別init (判斷是否清除主類別)
  var child_id;
  late Map errorText = {
    'clock_context': null,
    'startTime': null,
    'endTime': null,
    'clock_type': null,
  };
  bool reset_child = false; //是否清除子類別key
  var user;
  late File img = File('your initial file');

  @override
  void initState() {
    initTypeSelection().then((val) {
      setState(() {
        allType = val;
      });
    });

    super.initState();
  }

  //todo:(更換來源)離線報工時
  Future initTypeSelection() async {
    try{
      dio.options.headers['Authorization'] = 'Bearer ${BlocProvider.of<UserCubit>(context).state.token}';
      api.Response res = await dio.post(
        'http://192.168.12.68:443/api/getClockTypeAPI', // TODO: URL 放至 env 相關設定
        // 'https://uathws.hwacom.com//api/getClocks', // TODO: URL 放至 env 相關設定
        data: {
          'case_no': 'no_case',
          'attr': 6,
          'has_case': 2 //無Case
        },
      );
      Map<String, dynamic> data = res.data;
      return data;
    }on api.DioError catch (e) {
      error_alert(tr('auth.connection_error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = BlocProvider.of<ThemeCubit>(context).state.themeMode;
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    final token = BlocProvider.of<UserCubit>(context).state.token;
    //no_case/case/定保/客訴
    final type = arguments['type'];

    String time_picker_placeholder = tr("clock.create.depart_time_labelText");
    return Scaffold(
      appBar: MainAppBar(
        title: tr("clock.appbar.create"),
        appBar: AppBar(),
      ),
      body: Material(
        color: Theme.of(context).colorScheme.background,
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: ListView(
              children: <Widget>[
                //類型
                Column(
                  children: [
                    input_title(tr("clock.create.attr"), true),
                    Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(tr("clock.create.attr_project")),
                          leading: Radio<SingingCharacter>(
                            fillColor: MaterialStateColor.resolveWith((states) =>
                            Theme.of(context).colorScheme.inverseSurface),
                            activeColor:
                            Theme.of(context).colorScheme.inverseSurface,
                            value: SingingCharacter.project,
                            groupValue: _character,
                            onChanged: (SingingCharacter? value) {
                              setState(() {
                                typeBoxSet = true;
                                typeBoxVisible = 1.0;
                                _character = value;
                                attr_id = 6;
                                type_init_value = false;
                                reset_child = true;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(tr("clock.create.attr_office")),
                          leading: Radio<SingingCharacter>(
                            fillColor: MaterialStateColor.resolveWith((states) =>
                            Theme.of(context).colorScheme.inverseSurface),
                            activeColor:
                            Theme.of(context).colorScheme.inverseSurface,
                            value: SingingCharacter.office,
                            groupValue: _character,
                            onChanged: (SingingCharacter? value) {
                              setState(() {
                                typeBoxSet = true;
                                typeBoxVisible = 1.0;
                                _character = value;
                                attr_id = 7;
                                type_init_value = false;
                                reset_child = true;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(tr("clock.create.attr_day_off")),
                          leading: Radio<SingingCharacter>(
                            fillColor: MaterialStateColor.resolveWith((states) =>
                            Theme.of(context).colorScheme.inverseSurface),
                            activeColor:
                            Theme.of(context).colorScheme.inverseSurface,
                            value: SingingCharacter.day_off,
                            groupValue: _character,
                            onChanged: (SingingCharacter? value) {
                              setState(() {
                                typeBoxVisible = 0.0;
                                _character = value;
                                type_init_value = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //Internal Order
                Column(
                  children: [
                    input_title(tr("clock.create.internal_order"), false),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: const OutlineInputBorder(),
                          labelText: tr("clock.create.internal_order_labelText"),
                          labelStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                //主、子類別下拉選單
                AnimatedOpacity(
                  opacity: typeBoxVisible,
                  duration: const Duration(seconds: 1),
                  child: Visibility(
                    visible: typeBoxSet,
                    child: Column(
                      children: <Widget>[
                        //主類別
                        Column(
                          children: <Widget>[
                            input_title(tr("clock.create.type"), true),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: ClockType(
                                allType: allType,
                                attr_id: attr_id,
                                callback: callback,
                                type_init_value: type_init_value,
                              ),
                            ),
                          ],
                        ),
                        //子類別
                        Column(
                          children: <Widget>[
                            input_title(tr("clock.create.child_type"), false),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: ClockChildType(
                                allType: allType,
                                attr_id: attr_id,
                                parent_id: parent_id,
                                child_call_back: child_call_back,
                                reset_child: reset_child,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onEnd: () {
                    if (typeBoxVisible == 0) {
                      setState(() {
                        typeBoxSet = false;
                      });
                    }
                  },
                ),
                //出發時間
                Column(
                  children: [
                    input_title(tr("clock.create.depart_time"), false),
                    TextFormField(
                      controller: _depart,
                      // inputFormatters: [],
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: const OutlineInputBorder(),
                        hintText: time_picker_placeholder,
                        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                        labelStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                        suffixIcon: date_picker(_depart),
                      ),
                    ),
                  ],
                ),
                //開始時間
                Column(
                  children: [
                    input_title(tr("clock.create.start_time"), true),
                    TextFormField(
                      controller: _start,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: const OutlineInputBorder(),
                        hintText: time_picker_placeholder,
                        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                        suffixIcon: date_picker(_start),
                        errorText: errorText['startTime'],
                      ),
                    ),
                  ],
                ),
                //結束時間
                Column(
                  children: [
                    input_title(tr("clock.create.end_time"), true),
                    TextFormField(
                      controller: _end,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: const OutlineInputBorder(),
                        hintText: time_picker_placeholder,
                        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                        suffixIcon: date_picker(_end),
                        errorText: errorText['endTime'],
                      ),
                    ),
                  ],
                ),
                //總時數
                Column(
                  children: [
                    input_title(tr("clock.create.total_hours"), true),
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: TextFormField(
                              controller: _totalHours,
                              enabled: false,
                              decoration: InputDecoration(
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 15),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                border: const OutlineInputBorder(),
                                hintText: tr("clock.create.hours"),
                                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                              ),
                            ),
                          ),
                        ),
                        ClipPath(
                          child: Card(
                            color: themeMode == ThemeMode.dark
                                ? Theme.of(context).colorScheme.surface
                                : MetronicTheme.light_primary,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5))),
                            child: IconButton(
                              onPressed: () {
                                countHours(token);
                              },
                              icon: Icon(Ionicons.calculator_outline),
                              color: themeMode == ThemeMode.dark
                                  ? Theme.of(context).textTheme.titleLarge!.color
                                  : MetronicTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //通勤時數
                Column(
                  children: [
                    input_title(tr("clock.create.traffic_hours"), true),
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: TextFormField(
                              controller: _departHour,
                              enabled: false,
                              decoration: InputDecoration(
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 15),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                border: const OutlineInputBorder(),
                                hintText: tr("clock.create.hours"),
                                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //工作時數
                Column(
                  children: [
                    input_title(tr("clock.create.work_hours"), true),
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: TextFormField(
                              controller: _worksHours,
                              enabled: false,
                              decoration: InputDecoration(
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 15),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                border: const OutlineInputBorder(),
                                hintText: tr("clock.create.hours"),
                                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //工作內容
                Column(
                  children: [
                    input_title(tr("clock.create.context"), true),
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: TextFormField(
                              controller: _clock_context,
                              maxLines: 5,
                              decoration: InputDecoration(
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 15),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                border: const OutlineInputBorder(),
                                hintText: tr("clock.create.hours"),
                                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                                errorText: errorText['clock_context'] ?? null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    input_title(tr("clock.create.file"), true),
                    Material(
                      color: Theme.of(context).colorScheme.background,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(img),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  alignment: Alignment.bottomRight,
                                  padding: const EdgeInsets.all(5.0),
                                  margin: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 8.0, color: Colors.white30),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  getImage(ImageSource.camera);
                                },
                                icon:Icon(Ionicons.camera_outline, color: Theme.of(context).colorScheme.primary),
                                label: Text(
                                  '相機',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  getImage(ImageSource.gallery);
                                },
                                icon:Icon(Ionicons.image_outline, color: Theme.of(context).colorScheme.primary),
                                label: Text(
                                  '相簿',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                        ],
                      ), // This trailing comma makes auto-formatting nicer for build methods.
                    )
                    // ClockFile()
                  ],
                ),
                //返回 儲存草稿 送審btn
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Ionicons.arrow_back,
                                color: themeMode == ThemeMode.dark
                                    ? Theme.of(context).textTheme.titleLarge!.color
                                    : MetronicTheme.dark),
                            label: Text(
                              tr('button.back'),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: themeMode == ThemeMode.dark
                                      ? Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .color
                                      : MetronicTheme.dark,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.only(
                                  left: 10, right: 15, top: 10, bottom: 10),
                              foregroundColor: Colors.red,
                              backgroundColor: themeMode == ThemeMode.dark
                                  ? Theme.of(context).colorScheme.surface
                                  : MetronicTheme.light_dark,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              subimt_clock(1, token);
                            },
                            icon: Icon(Ionicons.pencil,
                                color: themeMode == ThemeMode.dark
                                    ? Theme.of(context).textTheme.titleLarge!.color
                                    : MetronicTheme.success),
                            label: Text(
                              tr('button.draft'),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: themeMode == ThemeMode.dark
                                      ? Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .color
                                      : MetronicTheme.success,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.only(
                                  left: 10, right: 15, top: 10, bottom: 10),
                              foregroundColor: Colors.red,
                              backgroundColor: themeMode == ThemeMode.dark
                                  ? Theme.of(context).colorScheme.surface
                                  : MetronicTheme.light_success,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              subimt_clock(2, token);
                            },
                            icon: Icon(Ionicons.checkmark_circle,
                                color: themeMode == ThemeMode.dark
                                    ? Theme.of(context).textTheme.titleLarge!.color
                                    : MetronicTheme.info),
                            label: Text(
                              tr('button.verify'),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: themeMode == ThemeMode.dark
                                      ? Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .color
                                      : MetronicTheme.info,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.only(
                                  left: 10, right: 15, top: 10, bottom: 10),
                              foregroundColor: Colors.red,
                              backgroundColor: themeMode == ThemeMode.dark
                                  ? Theme.of(context).colorScheme.surface
                                  : MetronicTheme.light_info,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  input_title(String string, require) {
    var require_span = const Text('');
    if (require) {
      require_span = const Text(
        '*',
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.red,
        ),
      );
    }
    return Row(
      children: [
        Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Text(
                  string,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                require_span,
              ],
            ),
        ),
      ],
    );
  }

  callback(id) {
    setState(() {
      parent_id = id;
      type_init_value = true;
      reset_child = true;
    });
  }

  child_call_back(id) {
    child_id = id;
    reset_child = false;
  }

  //計算工時
  countHours(token) async {
    try {
      setState(() {
        errorText['startTime'] = null;
        errorText['endTime'] = null;
      });
      dio.options.headers['Authorization'] = 'Bearer ${token}';
      api.Response res = await dio.post(
        'http://192.168.12.68:443/api/countHoursAPI', // TODO: URL 放至 env 相關設定
        data: {
          'departTime': _depart.text,
          'startTime': _start.text,
          'endTime': _end.text,
        },
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200 && res.data != null) {
        _departHour.text =
            res.data['data']['trafficHours']; // + tr('clock.create.h')
        _totalHours.text =
            res.data['data']['totalHours'];
        _worksHours.text =
            res.data['data']['worksHours'];
      }
    } on api.DioError catch (e) {
      _departHour.text = '';
      _totalHours.text = '';
      _worksHours.text = '';

      var message = e.response!.data['message'];
      var error = json.decode(message);

      if (error['error'] != null) {
        Alert(
          context: context,
          style: AlertStyles().dangerStyle(context),
          image: const ErrorIcon(),
          title: tr('alerts.confirm_error'),
          desc: "${error['error']}",
          buttons: [
            AlertStyles().getCancelButton(context),
          ],
        ).show();
      } else {
        setState(() {
          error.forEach((k, v) {
            errorText['${k}'] = '此欄位必塡';
          });
        });
      }
    }
  }

  //登錄工時
  subimt_clock(draft, token) async {
    bool check = true;
    setState(() {
      errorText.forEach((k, v) {
        errorText[k] = null;
      });

      if (_clock_context.text.isEmpty) {
        errorText['clock_context'] = '此欄位必塡';
        check = false;
      }

      if (_start.text.isEmpty) {
        errorText['startTime'] = '此欄位必塡';
        check = false;
      }

      if (_end.text.isEmpty) {
        errorText['endTime'] = '此欄位必塡';
        check = false;
      }

      if (_totalHours.text.isEmpty) {
        error_alert('請先計算工時！');
        check = false;
      }
    });

    if (check) {
      try {
        if (attr_id == 8) {
          parent_id = 9;
        }

        // var file = await ImageController().imgData;
        dio.options.headers['Authorization'] = 'Bearer ${token}';
        api.FormData formData = api.FormData.fromMap({
          "files[]": await api.MultipartFile.fromFile(
            img.path,
            filename: img.path.split("image_picker").last,
          ),
            'context': _clock_context.text,
            'type': child_id,
            'clock_type': parent_id,
            'departTime': _depart.text,
            'startTime': _start.text, //_start.text
            'endTime': _end.text, //_end.text
            'total_hours': _totalHours.text,
            'clock_attribute': attr_id,
            'draft': draft,
            // 'context': '123132',
            // 'type': 7,
            // 'clock_type': 8,
            // 'departTime': DateFormat('yyyy-MM-dd 00:00').format(DateTime.now()),
            // 'startTime': DateFormat('yyyy-MM-dd 00:00').format(DateTime.now()), //_start.text
            // 'endTime': DateFormat('yyyy-MM-dd 00:30').format(DateTime.now()), //_end.text
            // 'total_hours': 1,
            // 'clock_attribute': 1,
            // 'draft': draft,
        });
        api.Response res = await dio.post(
          'http://192.168.12.68:443/api/storeClockAPI',data: formData
        );

        if (res.data != null) {
          Alert(
            context: context,
            style: AlertStyles().successStyle(context),
            image: SuccessIcon(),
            title: tr('alerts.confirm_success'),
            desc: tr('alerts.confirm_done_info'),
            buttons: [
              AlertStyles().getDoneButton(context, '/clock_list'),
            ],
          ).show();
        }
      } on api.DioError catch (e) {
        var message = e.response!.data['message'];
        var error = json.decode(message);

        if (error['error'] != null) {
          error_alert("${error['error']}");
        } else {
          if (error['clock_type'] != null) {
            error_alert("請選擇主類別！");
          } else {
            setState(() {
              error.forEach((k, v) {
                errorText['${k}'] = '此欄位必塡';
              });
            });
          }
        }
      }
    }
  }

  //錯誤訊息alert
  error_alert(msg) {
    return Alert(
      context: context,
      style: AlertStyles().dangerStyle(context),
      image: const ErrorIcon(),
      title: tr('alerts.confirm_error'),
      desc: msg,
      buttons: [
        AlertStyles().getCancelButton(context),
      ],
    ).show();
  }

  date_picker(controller) {
    return IconButton(
      onPressed: () {
        DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          onConfirm: (date) {
            var seconds = int.parse(DateFormat('mm').format(date));
            if (seconds < 15) {
              controller.text = DateFormat('yyyy-MM-dd kk:00').format(date);
            } else if (seconds >= 15 && seconds < 45) {
              controller.text = DateFormat('yyyy-MM-dd kk:30').format(date);
            } else {
              var new_date = date.add(Duration(hours: 1));
              //跨天
              if (int.parse(DateFormat('kk').format(new_date)) == 24) {
                controller.text =
                    DateFormat('yyyy-MM-dd 00:00').format(new_date);
              } else {
                controller.text =
                    DateFormat('yyyy-MM-dd kk:00').format(new_date);
              }
            }
          },
          currentTime: DateTime.now(),
          locale: LocaleType.zh,
        );
      },
      icon: Icon(
        Ionicons.calendar_outline,
        color: Theme.of(context).textTheme.titleLarge!.color,
      ),
    );
  }

  ///寫入圖片
  Future<void> getImage(ImageSource source) async{
    // Step 1: 彈出圖片選擇
    final XFile? image = await ImagePicker().pickImage(source: source);
    
    // Step 2: 判斷是否有選擇到圖片
    if (image == null) return;
    
    // Step 3: 取得檔案目錄.
    final dir = await getTemporaryDirectory();
    // Step 4: 複製檔案到儲存目錄;
    // final localImage = await image.saveTo(directory.path + image.name);

    await cropImage(image.path);
    //GallerySaver.saveImage(imageFilePath);
    // var imgFile = GallerySaver.saveImage(imageFilePath);
    // setState(() {
    //   img = imageFile;
    // });
  }

  Future cropImage(String pickedFilePath) async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFilePath,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.original,
          //CropAspectRatioPreset.ratio4x3,
          //CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          //CropAspectRatioPreset.ratio4x3,
          //CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blueAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(title: 'Cropper'));
    if (croppedFile != null) {
      setState(() {
        img = croppedFile;
      });
      return croppedFile;
    } else {
      return null;
    }
  }

}
