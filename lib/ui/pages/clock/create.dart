import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:hive/hive.dart';
import 'package:hws_app/ui/widgets/alert/alert_icons.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../config/setting.dart';
import '../../../config/theme.dart';
import '../../../cubit/clock_cubit.dart';
import '../../../cubit/theme_cubit.dart';
import '../../../cubit/user_cubit.dart';
import '../../../models/toBeSyncClock.dart';
import '../../../service/ClockInfo.dart';
import '../../../service/ImageController.dart';
import '../../widgets/alert/icons/error_icon.dart';
import '../../widgets/alert/styles.dart';
import '../../widgets/clock/clock_child_type.dart';
import '../../widgets/clock/clock_type.dart';
import '../../widgets/common/main_appbar.dart';

import 'package:dio/dio.dart' as api;
import 'dart:developer' as developer;

enum SingingCharacter { project, office, day_off }

class CreateClock extends StatefulWidget {
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
  var typeBoxVisible = 1.0; //主子類別透明度(無CASE)
  var caseTypeBoxVisible = 0.0; //主子類別透明度(有CASE)
  bool typeBoxSet = true; //主子類別調完透明度調整空間(無CASE)
  bool caseTypeBoxSet = false; //主子類別調完透明度調整空間(有CASE)
  int attr_id = 6; //預設屬性id
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
  late Map userCase = Map();
  var case_number = 'no_case'; //無Case
  File? img;
  late String sale_type = '';
  late final Box toBeSyncClockBox = Hive.box('toBeSyncClockBox');


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  ///User Case下拉選單
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Map arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;
      String type = arguments['type'];
      int has_case = 2; //無case
      switch (type) {
        case 'has_case':
          has_case = 1;
          getUserCase().then((val) {
            setState(() {
              userCase = val;
            });
          });
          break;
      }

      initTypeSelection(has_case).then((val) {
        setState(() {
          allType = val;
        });
      });
    });
    super.initState();
  }

  Future initTypeSelection(has_case) async {
      var res = BlocProvider.of<ClockCubit>(context).state.toMap();
      Map<String, dynamic> data = res['clockType'];
      return data;
  }

  Future getUserCase() async {
    var res = BlocProvider.of<ClockCubit>(context).state.toMap();
    Map<String, dynamic> data = res['userCase'];
    return data;
  }

  @override
  Widget build(BuildContext context) {
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
        isPop: false,
      ),
      body: Material(
        color: Theme.of(context).colorScheme.background,
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: ListView(
              children: <Widget>[
                type == 'has_case' ? caseBox(userCase) : Column(
                  children: [
                    inputTitle(tr("clock.create.attr"), true),
                    Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(tr("clock.create.attr_project")),
                          leading: Radio<SingingCharacter>(
                            fillColor: MaterialStateColor.resolveWith(
                                    (states) => Theme.of(context)
                                    .colorScheme
                                    .inverseSurface),
                            activeColor: Theme.of(context)
                                .colorScheme
                                .inverseSurface,
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
                            fillColor: MaterialStateColor.resolveWith(
                                    (states) => Theme.of(context)
                                    .colorScheme
                                    .inverseSurface),
                            activeColor: Theme.of(context)
                                .colorScheme
                                .inverseSurface,
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
                            fillColor: MaterialStateColor.resolveWith(
                                    (states) => Theme.of(context)
                                    .colorScheme
                                    .inverseSurface),
                            activeColor: Theme.of(context)
                                .colorScheme
                                .inverseSurface,
                            value: SingingCharacter.day_off,
                            groupValue: _character,
                            onChanged: (SingingCharacter? value) {
                              setState(() {
                                typeBoxVisible = 0.0;
                                _character = value;
                                type_init_value = true;
                                attr_id = 8;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    inputTitle(tr("clock.create.internal_order"), false),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                          filled: true,
                          fillColor:
                          Theme.of(context).colorScheme.surface,
                          border: const OutlineInputBorder(),
                          labelText:
                          tr("clock.create.internal_order_labelText"),
                          labelStyle: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                //主、子類別下拉選單
                AnimatedOpacity(
                  opacity: type == 'no_case' ? typeBoxVisible : caseTypeBoxVisible,
                  duration: const Duration(seconds: 1),
                  child: Visibility(
                    visible: type == 'no_case' ? typeBoxSet : caseTypeBoxSet,
                    child: Column(
                      children: <Widget>[
                        //主類別
                        Column(
                          children: <Widget>[
                            inputTitle(tr("clock.create.type"), true),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: ClockType(
                                allType: allType,
                                attr_id: attr_id,
                                callback: callback,
                                type_init_value: type_init_value,
                                has_case: type,
                                parent_id: parent_id,
                              ),
                            ),
                          ],
                        ),
                        //子類別
                        Column(
                          children: <Widget>[
                            inputTitle(tr("clock.create.child_type"), false),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: ClockChildType(
                                allType: allType,
                                attr_id: attr_id,
                                parent_id: parent_id,
                                childCallback: childCallback,
                                reset_child: reset_child,
                                child_id: child_id
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
                    inputTitle(tr("clock.create.depart_time"), false),
                    TextFormField(
                      //todo:優化date欄位input format
                      controller: _depart,
                      // inputFormatters: [],
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: const OutlineInputBorder(),
                        hintText: time_picker_placeholder,
                        hintStyle: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodySmall!.color),
                        labelStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                        suffixIcon: datePicker(_depart),
                      ),
                    ),
                  ],
                ),
                //開始時間
                Column(
                  children: [
                    inputTitle(tr("clock.create.start_time"), true),
                    TextFormField(
                      controller: _start,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: const OutlineInputBorder(),
                        hintText: time_picker_placeholder,
                        hintStyle: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodySmall!.color),
                        suffixIcon: datePicker(_start),
                        errorText: errorText['startTime'],
                      ),
                    ),
                  ],
                ),
                //結束時間
                Column(
                  children: [
                    inputTitle(tr("clock.create.end_time"), true),
                    TextFormField(
                      controller: _end,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: const OutlineInputBorder(),
                        hintText: time_picker_placeholder,
                        hintStyle: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodySmall!.color),
                        suffixIcon: datePicker(_end),
                        errorText: errorText['endTime'],
                      ),
                    ),
                  ],
                ),
                //總時數
                Column(
                  children: [
                    inputTitle(tr("clock.create.total_hours"), true),
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
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                border: const OutlineInputBorder(),
                                hintText: tr("clock.create.hours"),
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color),
                              ),
                            ),
                          ),
                        ),
                        ClipPath(
                          child: Card(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.surface
                                : MetronicTheme.light_primary,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: IconButton(
                              onPressed: () {
                                ///利用網路判斷本地計算還是透過API
                                ///var user = BlocProvider.of<UserCubit>(context).state;
                                ///user.networkEnable ? countHoursAPI(token) :countHours(token);
                                ///穩定先本地計算
                                countHours(token);
                              },
                              icon: Icon(Ionicons.calculator_outline),
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .color
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
                    inputTitle(tr("clock.create.traffic_hours"), true),
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
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                border: const OutlineInputBorder(),
                                hintText: tr("clock.create.hours"),
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color),
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
                    inputTitle(tr("clock.create.work_hours"), true),
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
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                border: const OutlineInputBorder(),
                                hintText: tr("clock.create.hours"),
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                ///工作內容
                Column(
                  children: [
                    inputTitle(tr("clock.create.context"), true),
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
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                border: const OutlineInputBorder(),
                                hintText: tr("clock.create.hours"),
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color),
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
                    inputTitle(tr("clock.create.file"), false),
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
                                  color: Theme.of(context).colorScheme.surface,
                                  image: img == null ? DecorationImage(
                                    image: AssetImage("assets/img/default_image.png"),
                                    fit: BoxFit.cover,
                                  ) :DecorationImage(
                                    image: FileImage(img!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  alignment: Alignment.bottomRight,
                                  padding: const EdgeInsets.all(5.0),
                                  margin: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 8.0, color: Colors.white30),
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
                                icon: Icon(Ionicons.camera_outline,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                label: Text(
                                  '相機',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .apply(
                                          fontWeightDelta: 2,
                                          fontSizeDelta: -2),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  getImage(ImageSource.gallery);
                                },
                                icon: Icon(Ionicons.image_outline,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                label: Text(
                                  '相簿',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .apply(
                                          fontWeightDelta: 2,
                                          fontSizeDelta: -2),
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
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .color
                                    : MetronicTheme.dark),
                            label: Text(
                              tr('button.back'),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
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
                              backgroundColor: Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.surface
                                  : MetronicTheme.light_dark,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              submitClock(1, token);
                            },
                            icon: Icon(Ionicons.pencil,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .color
                                    : MetronicTheme.success),
                            label: Text(
                              tr('button.draft'),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
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
                              backgroundColor: Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.surface
                                  : MetronicTheme.light_success,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              submitClock(2, token);
                            },
                            icon: Icon(Ionicons.checkmark_circle,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .color
                                    : MetronicTheme.info),
                            label: Text(
                              tr('button.verify'),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
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
                              backgroundColor: Theme.of(context).brightness == Brightness.dark
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

  inputTitle(String string, require) {
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

  childCallback(id) {
    setState(() {
      child_id = id;
    });
    reset_child = false;
  }

  //計算工時
  countHours(token) async {
    developer.log("Count and Check Local");
    var res = BlocProvider.of<ClockCubit>(context).state.toMap();
    try {
      setState(() {
        errorText['startTime'] = null;
        errorText['endTime'] = null;
      });

      if (_start.text.isEmpty) {
        errorText['startTime'] = tr('validation.require');
      }

      if (_end.text.isEmpty) {
        errorText['endTime'] = tr('validation.require');
      }

      ///字串轉DateTime格式
      DateTime departTime = DateTime.parse(_depart.text == '' ? _start.text : _depart.text);
      DateTime startTime = DateTime.parse(_start.text);
      DateTime endTime = DateTime.parse(_end.text);

      ///TODO:修改工時將ID帶入做判斷
      ClockInfo().CheckClock('id',departTime, endTime, res['monthly']).then((res) {
        print('Check can Clocking?');
        print(res);
        if(res['success']){
          _departHour.text = "${startTime.difference(departTime).inMinutes / 60}";
          _worksHours.text = "${endTime.difference(startTime).inMinutes / 60}";
          _totalHours.text = "${endTime.difference(departTime).inMinutes / 60}";
        }else{
          Alert(
            context: context,
            style: AlertStyles().dangerStyle(context),
            image: const ErrorIcon(),
            title: tr('alerts.confirm_error'),
            desc: "${res['message']}",
            buttons: [
              AlertStyles().getCancelButton(context),
            ],
          ).show();
        }
      });

    }catch(e){
      developer.log("Required startTime & endTime");
    }
  }

  //計算工時API
  countHoursAPI(token) async {
    developer.log("Count and Check API");
    //todo 日期格式判斷
    try {
      setState(() {
        errorText['startTime'] = null;
        errorText['endTime'] = null;
      });

      if (_start.text.isEmpty) {
        errorText['startTime'] = tr('validation.require');
      }

      if (_end.text.isEmpty) {
        errorText['endTime'] = tr('validation.require');
      }

      dio.options.headers['Authorization'] = 'Bearer ${token}';
      api.Response res = await dio.post(
        '${InitSettings.apiUrl}:443/api/countHoursAPI', // TODO: URL 放至 env 相關設定
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
            errorText['${k}'] = tr('validation.require');
          });
        });
      }
    }
  }

  //登錄工時
  submitClock(draft, token) async {
    bool check = true;
    setState(() {
      errorText.forEach((k, v) {
        errorText[k] = null;
      });

      if (_clock_context.text.isEmpty) {
        errorText['clock_context'] = tr('validation.require');
        check = false;
      }

      if (_start.text.isEmpty) {
        errorText['startTime'] = tr('validation.require');
        check = false;
      }

      if (_end.text.isEmpty) {
        errorText['endTime'] = tr('validation.require');
        check = false;
      }

      if (_totalHours.text.isEmpty) {
        errorAlert(tr('clock.create.count_error'));
        check = false;
      }
    });

    if (check) {
        if (attr_id == 8) {
          parent_id = 9;
        }

        var files = img == null ? null : await api.MultipartFile.fromFile(
          img!.path,
          filename: img!.path.split("image_picker").last,
        );

        Map clockData = {
          'id': '',
          'type': child_id,
          'clock_attribute': '$attr_id',
          'clocking_no': '',
          'source_no': '',
          'enumber': '',
          'bu_code': '',
          'dept_code': '',
          'project_id': '',
          'context': _clock_context.text,
          'function_code': '',
          'direct_code': '',
          'traffic_hours': double.parse(_departHour.text),
          'worked_hours': double.parse(_worksHours.text),
          'total_hours': double.parse(_totalHours.text),
          'depart_time': _depart.text == '' ? _start.text : _depart.text,
          'start_time': _start.text,
          'end_time': _end.text,
          'status': draft,
          'created_at': '',
          'updated_at': '',
          'deleted_at': '',
          'sales_enumber': '',
          'sales_bu_code': '',
          'sales_dept_code': '',
          'sap_wbs': '',
          'order_date': '',
          'internal_order': '',
          'bpm_number': '',
          'case_no': case_number == 'no_case' ? '' : case_number,
          'images': '$files',
          'sync_status': '1',
          'clock_type': parent_id,
          'sale_type': sale_type
        };

        ClockInfo().InsertClock(clockData).then((res){
          if (res) {
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
          }else{
            errorAlert(tr('alerts.clock_store_error'));
          }
        });

        ///TODO:API上傳報工紀錄error handle
        // var message = e.response!.data['message'];
        // var error = json.decode(message);
        //
        // if (error['error'] != null) {
        //   errorAlert("${error['error']}");
        // } else {
        //   if (error['clock_type'] != null) {
        //     errorAlert("請選擇主類別！");
        //   } else {
        //     setState(() {
        //       error.forEach((k, v) {
        //         errorText['${k}'] = tr('validation.require');
        //       });
        //     });
        //   }
        // }

    }
  }

  //錯誤訊息alert
  errorAlert(msg) {
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

  datePicker(controller) {
    return IconButton(
      onPressed: () {
        DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          onConfirm: (date) {
            var minutes = int.parse(DateFormat('mm').format(date));
            if (minutes < 15) {
              controller.text = DateFormat('yyyy-MM-dd HH:00').format(date);
            } else if (minutes >= 15 && minutes < 45) {
              controller.text = DateFormat('yyyy-MM-dd HH:30').format(date);
            } else {
              var new_date = date.add(Duration(hours: 1));
              controller.text = DateFormat('yyyy-MM-dd HH:00').format(new_date);
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
  Future<void> getImage(ImageSource source) async {
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

  caseBox(userCase) {
    List<DropdownMenuItem> dynamicMenus = [];
    if (userCase.isNotEmpty) {
      userCase.forEach((k, v) {
        dynamicMenus.add(
          DropdownMenuItem(
              key: ValueKey(k), value: '$k', child: Text(v['name'])),
        );
      });
    }
    return Column(
      children: [
        inputTitle(tr("clock.create.case_no"), true),
        DropdownButtonFormField(
          isExpanded: true,
          value: case_number,
          dropdownColor: Theme.of(context).colorScheme.surface,
          icon: Icon(
            Ionicons.caret_down_outline,
            color: Theme.of(context).textTheme.bodySmall!.color,
          ),
          hint: Text(
            tr("clock.create.case_no_hint"),
            style:
                TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
          ),
          items: dynamicMenus,
          onChanged: (value) {
            checkCaseType(value);
            case_number = value;
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  checkCaseType(case_no) {
    Map info = userCase[case_no]['info'];
    initTypeSelection(1).then((val) {
      setState(() {
        attr_id = info['sale_type'] == 'pre' ? 1 : 5;
        sale_type = info['sale_type'];
        type_init_value = false;
        reset_child = true;
        caseTypeBoxSet = true;
        caseTypeBoxVisible = 1.0;
        case_number = case_no;
      });
    });
  }
}

