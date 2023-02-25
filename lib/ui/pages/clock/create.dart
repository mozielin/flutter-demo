import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
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
  final _depart = TextEditingController(); //出發時間
  final _start = TextEditingController(); //開始時間
  final _end = TextEditingController(); //結束時間
  final _departHours = TextEditingController(); //通勤時數
  final _totalHours = TextEditingController(); //總時數
  final _worksHours = TextEditingController(); //工作時數
  final _clock_context = TextEditingController(); //工作內容
  final _internal_order = TextEditingController(); //internal_order

  late Map allType = Map(); //屬性、主、子類別
  late Map userCase = Map();
  late Map errorText = {
    'clock_context': null,
    'startTime': null,
    'endTime': null,
    'clock_type': null,
    'parent_id': null,
  };
  late String sale_type = '';
  late final Box toBeSyncClockBox = Hive.box('toBeSyncClockBox');

  bool typeBoxSet = true; //主子類別調完透明度調整空間(無CASE)
  bool caseTypeBoxSet = false; //主子類別調完透明度調整空間(有CASE)
  bool type_init_value = true; //是否為主類別init (判斷是否清除主類別)
  bool reset_child = false; //是否清除子類別key
  bool hideTypeBox = false; //是否隱藏主/子類別
  bool rebuild = false; //判斷是否Rebuild過

  var typeBoxVisible = 1.0; //主子類別透明度(無CASE)
  var caseTypeBoxVisible = 0.0; //主子類別透明度(有CASE)
  var parent_id;
  var child_id;
  var user;
  var case_number = 'no_case'; //無Case

  SingingCharacter? _character = SingingCharacter.project;
  String img64 = '[]';
  int attr_id = 6;
  Io.File? img;

  @override
  void dispose() {
    try{
      img?.delete();
    }catch(e){
      developer.log('$e');
    }
    super.dispose();
  }

  ///User Case下拉選單
  @override
  void initState() {
    super.initState();
  }

  @override
  didChangeDependencies(){
    Map arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    String type = arguments['type'];
    if (type == 'has_case') hideTypeBox = true;
    int has_case = 2; //無case
    switch (type) {
      case 'has_case':
        has_case = 1;
        var res = getUserCase();
        setState(() {
          userCase = res;
        });
        break;
    }

    var res = initTypeSelection(has_case);

    setState(() {
      allType = res;
    });

    var data;
    //int attr_id; //預設屬性id

    ///Edit代入資料
    if(arguments.containsKey("data")){
      data = arguments['data'];
      hideTypeBox = false;
      _clock_context.text = data.context;
      _depart.text = data.depart_time;
      _start.text = data.start_time;
      _end.text = data.end_time;
      _totalHours.text = data.total_hours.toString();
      _worksHours.text = data.worked_hours.toString();
      _departHours.text = data.traffic_hours.toString();
      _internal_order.text = data.internal_order;
      attr_id = int.parse(data.clock_attribute);
      parent_id = data.clock_type;
      child_id = data.type == '' ? null :data.type;
      case_number = data.case_no;
      sale_type = data.sale_type;

      ///無case
      switch(data.clock_attribute){
        case '6':
          _character = SingingCharacter.project;
          break;
        case '7':
          _character = SingingCharacter.office;
          break;
        case '8':
          _character = SingingCharacter.day_off;
          break;
      }

      if (data.clock_attribute == '8' && data.case_no == '') hideTypeBox = true;

      ///TODO:檔案結構更改
      ///將hive的圖片base64取出轉成臨時的File插入
      if (data.images != '[]') {
        ///TODO:檔案結構更改
        writeFile(jsonDecode(data.images), data.id).then((res){
          img = res;
          if (!rebuild) setState(() {});
          rebuild = true;
        });
      }
    }

    super.didChangeDependencies();
  }

  initTypeSelection(has_case) {
      var res = BlocProvider.of<ClockCubit>(context).state.toMap();
      Map<String, dynamic> data = res['clockType'];
      return data;
  }

  getUserCase() {
    var res = BlocProvider.of<ClockCubit>(context).state.toMap();
    Map<String, dynamic> data = res['userCase'];
    return data;
  }

  ///TODO:檔案結構更改
  writeFile(base64, id) async {
    final decodedBytes = base64Decode(base64[0]);
    final tempDir = await getTemporaryDirectory();
    final directory = await Io.Directory('${tempDir.path}/editClockTempImg').create(recursive: true);
    img = Io.File('${directory.path}/$id.png');
    img?.writeAsBytesSync(List.from(decodedBytes));
    return img;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    final token = BlocProvider.of<UserCubit>(context).state.token;
    //no_case/case/定保/客訴
    final type = arguments['type'];
    var data;
    //int attr_id; //預設屬性id

    ///Edit代入資料
    if(arguments.containsKey("data")){
      data = arguments['data'];
    }

    String time_picker_placeholder = tr("clock.create.depart_time_labelText");
    return Scaffold(
      appBar: MainAppBar(
        title: data == null ? tr("clock.appbar.create") : tr("clock.appbar.edit"),
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
                ///Case選擇 or 無Case attribute選擇
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
                                hideTypeBox = false;
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
                                hideTypeBox = false;
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
                                type_init_value = false;
                                attr_id = 8;
                                reset_child = true;
                                hideTypeBox = true;
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
                        controller: _internal_order,
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
                ///主、子類別下拉選單
                AnimatedOpacity(
                  opacity: !hideTypeBox ? typeBoxVisible : caseTypeBoxVisible,
                  duration: const Duration(seconds: 1),
                  child: Visibility(
                    visible: !hideTypeBox ? typeBoxSet : caseTypeBoxSet,
                    child: Column(
                      children: <Widget>[
                        //主類別
                        Column(
                          children: <Widget>[
                            inputTitle(tr("clock.create.type"), true),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: allType.isNotEmpty ? ClockType(
                                allType: allType,
                                attr_id: attr_id,
                                callback: callback,
                                type_init_value: type_init_value,
                                has_case: type,
                                parent_id: parent_id,
                              ):SizedBox()
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
                ///出發時間
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
                ///開始時間
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
                ///結束時間
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
                ///總時數
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
                              onEditingComplete: (){

                              },
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
                                countHours(token, data);
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
                ///通勤時數
                Column(
                  children: [
                    inputTitle(tr("clock.create.traffic_hours"), true),
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: TextFormField(
                              controller: _departHours,
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
                ///工作時數
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
                            child: GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).requestFocus(FocusNode());
                                      },
                                      child: Container(
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisAlignment:  MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            TextFormField(
                                              controller: _clock_context,
                                              maxLines: 5,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                const EdgeInsets.symmetric(horizontal: 15),
                                                filled: true,
                                                fillColor:
                                                Theme.of(context).colorScheme.surface,
                                                border: const OutlineInputBorder(),
                                                hintText: tr("clock.create.context_labelText"),
                                                hintStyle: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .color),
                                                errorText: errorText['clock_context'] ?? null,
                                              ),
                                            )
                                          ],
                                        )
                                      )
                                    )
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ///File
                ///TODO:檔案結構更改
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
                                  image: img == null ? const DecorationImage(
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
                              ///刪除
                              TextButton.icon(
                                onPressed: () async {
                                  deleteImage(img);
                                },
                                icon: Icon(Ionicons.trash_outline,
                                    color:
                                    Theme.of(context).colorScheme.primary),
                                label: Text(
                                  tr('clock.create.img_delete'),
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
                              ///相機
                              TextButton.icon(
                                onPressed: () async {
                                  getImage(ImageSource.camera);
                                },
                                icon: Icon(Ionicons.camera_outline,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                label: Text(
                                  tr('clock.create.img_camera'),
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
                              ///相簿
                              TextButton.icon(
                                onPressed: () async {
                                  getImage(ImageSource.gallery);
                                },
                                icon: Icon(Ionicons.image_outline,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                label: Text(
                                  tr('clock.create.img_album'),
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ///返回
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Ionicons.arrow_back,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context).colorScheme.primary
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
                              padding: const EdgeInsets.only(
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
                          if(data == null || data.status != '6')
                            ///草稿
                            TextButton.icon(
                              onPressed: () {
                                submitClock(1, token, data);
                              },
                              icon: Icon(Ionicons.pencil,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Theme.of(context).colorScheme.primary
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
                          ///送審
                          TextButton.icon(
                            onPressed: () {
                              submitClock(2, token, data);
                            },
                            icon: Icon(Ionicons.checkmark_circle,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context).colorScheme.primary
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

  ///計算工時
  countHours(token, data) async {
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

      ClockInfo().CheckClock(data == null ? 'id' : data.id, departTime, startTime, endTime, res['monthly']).then((res) {
        if(res['success']){
          _departHours.text = "${startTime.difference(departTime).inMinutes / 60}";
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

  ///登錄工時
  submitClock(draft, token, data) async {
    var res = BlocProvider.of<ClockCubit>(context).state.toMap();
    bool check = true;
    ///類型為請假時 parent_id = 9
    if (attr_id == 8) {
      parent_id = 9;
    }
    setState(() {
      errorText.forEach((k, v) {
        errorText[k] = null;
      });

      if (parent_id == null) {
        errorAlert("請選擇主類別！");
        // errorText['clock_type'] = tr('validation.require');
        check = false;
      }

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
      ///字串轉DateTime格式
      DateTime departTime = DateTime.parse(_depart.text == '' ? _start.text : _depart.text);
      DateTime startTime = DateTime.parse(_start.text);
      DateTime endTime = DateTime.parse(_end.text);

      ClockInfo().CheckClock(data == null ? 'id' : data.id,departTime,startTime, endTime, res['monthly']).then((res) {
        if(res['success']){

          ///圖片轉為base64在array裡轉成Json儲存
          if(img != null){
            final bytes = Io.File(img!.path).readAsBytesSync();
            img64 = json.encode([base64Encode(bytes)]);
          }

          Map clockData = {
            'id': data == null ? '' : data.id,
            'type': child_id,
            'clock_attribute': attr_id,
            'clocking_no': '',
            'source_no': '',
            'enumber': '',
            'bu_code': '',
            'dept_code': '',
            'project_id': '',
            'context': _clock_context.text,
            'function_code': '',
            'direct_code': '',
            'traffic_hours': double.parse(_departHours.text),
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
            'internal_order': _internal_order.text,
            'bpm_number': '',
            'case_no': case_number == 'no_case' ? '' : case_number,
            'images': img64,
            'sync_status': '1',
            'clock_type': parent_id,
            'sale_type': sale_type,
            'is_verify': '0'
          };

          ///送審時提示訊息
          if(draft == 2) {
            Alert(
              context: context,
              style: AlertStyles().warningStyle(context),
              image: const WarningIcon(),
              title: tr('clock.alerts.warning_verify'),
              desc: tr('clock.alerts.verify'),
              buttons: [
                AlertStyles().getCancelButton(context),
                DialogButton(
                  width: 200,
                  color: Theme.of(context).colorScheme.surface,
                  child: Text(
                  tr('alerts.confirm'),
                  style: Theme.of(context).textTheme.titleLarge!.apply(fontWeightDelta: 2, fontSizeDelta: -2),
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                    ClockInfo().InsertClock(clockData).then((res){
                      if (res) {
                        ///TODO:優化-點擊物理返回鍵會回到剛剛報工form，攔截或取消物理返回
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
                  },
                ),
              ],
            ).show();
          }else{
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
          }

        }else{
          check = false;
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

  ///計算工時API
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
        _departHours.text =
        res.data['data']['trafficHours']; // + tr('clock.create.h')
        _totalHours.text =
        res.data['data']['totalHours'];
        _worksHours.text =
        res.data['data']['worksHours'];
      }
    } on api.DioError catch (e) {
      _departHours.text = '';
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

  ///登錄工時API
  submitClockAPI(draft, token) async {
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
      try {
        if (attr_id == 8) {
          parent_id = 9;
        }

        // var file = await ImageController().imgData;
        dio.options.headers['Authorization'] = 'Bearer ${token}';
        api.FormData formData = api.FormData.fromMap({
          "files[]": await api.MultipartFile.fromFile(
            img!.path,
            filename: img?.path.split("image_picker").last,
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
            '${InitSettings.apiUrl}:443/api/clock',data: formData
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
          errorAlert("${error['error']}");
        } else {
          if (error['clock_type'] != null) {
            errorAlert("請選擇主類別！");
          } else {
            setState(() {
              error.forEach((k, v) {
                errorText['${k}'] = tr('validation.require');
              });
            });
          }
        }
      }
    }
  }

  ///錯誤訊息alert
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
        /// 清空時間計算欄位
        _departHours.clear();
        _worksHours.clear();
        _totalHours.clear();
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
    Io.File? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFilePath,
        aspectRatioPresets: Io.Platform.isAndroid
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
          value: case_number == 'no_case' ? null : case_number,
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

      setState(() {
        attr_id = info['sale_type'] == 'pre' ? 1 : 5;
        sale_type = info['sale_type'];
        type_init_value = false;
        reset_child = true;
        caseTypeBoxSet = true;
        caseTypeBoxVisible = 1.0;
        case_number = case_no;
      });

  }

  bool deleteImage(image) {
    try{
      if(img != null){
        Alert(
          context: context,
          style: AlertStyles().warningStyle(context),
          image: const WarningIcon(),
          title: tr('clock.alerts.warning_delete'),
          desc: tr('clock.alerts.file_delete'),
          buttons: [
            AlertStyles().getCancelButton(context),
            DialogButton(
              width: 200,
              color: Theme.of(context).colorScheme.surface,
              child: Text(
                tr('alerts.confirm'),
                style: Theme.of(context).textTheme.titleLarge!.apply(fontWeightDelta: 2, fontSizeDelta: -2),
              ),
              onPressed: (){
                Navigator.pop(context);
                image?.delete();
                setState(() {
                  img = null;
                });
              },
            ),
          ],
        ).show();
      }
      return true;
    }catch(e){
      return false;
    }
  }
}

