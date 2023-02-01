import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:ionicons/ionicons.dart';

import '../../../config/theme.dart';
import '../../widgets/clock/clock_child_type.dart';
import '../../widgets/clock/clock_type.dart';
import '../../widgets/common/main_appbar.dart';
import 'custom_picker.dart';
import 'package:dio/dio.dart';

enum SingingCharacter { project, office, day_off }

class CreateClock extends StatefulWidget {
  @override
  State<CreateClock> createState() => _CreateClockState();
}

class _CreateClockState extends State<CreateClock> {
  final Dio dio = Dio();
  SingingCharacter? _character = SingingCharacter.project;
  final ScrollController scrollController = ScrollController();
  final _depart = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _departHour = TextEditingController();
  final _totalHours = TextEditingController();
  final _worksHours = TextEditingController();
  final clock_context = TextEditingController();
  late Map allType = Map();
  var _typeBoxVisible = 1.0;
  var _typeBoxSet = true;
  bool showbtn = false;
  var type_id = 6;
  var parent_id;
  var type_init_value = true;

  @override
  void initState() {
    initTypeSelection().then((val) {
      setState(() {
        allType = val;
      });
    });

    scrollController.addListener(() {
      double showOffset = 10.0;

      if (scrollController.offset > showOffset) {
        setState(() {
          showbtn = true;
        });
      } else {
        setState(() {
          showbtn = false;
        });
      }
    });
    super.initState();
  }

  Future initTypeSelection() async {
    print('future work');

    dio.options.headers['Authorization'] =
        'Bearer 515|eM1k7UlR33lFFJLFhtm6exPkIaLcXXrJk2qWoNh9'; // TODO: 統一設定
    Response res = await dio.post(
      'http://10.0.2.2/api/getClockTypeAPI', // TODO: URL 放至 env 相關設定
      // 'https://uathws.hwacom.com//api/getClocks', // TODO: URL 放至 env 相關設定
      data: {
        'case_no': 'no_case',
        'attr': 6,
      },
    );
    Map<String, dynamic> data = res.data;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    final type = arguments['type'];
    String _input = tr("clock.create.depart_time_labelText");
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
              controller: scrollController,
              children: <Widget>[
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
                            _typeBoxSet = true;
                            _typeBoxVisible = 1.0;
                            _character = value;
                            type_id = 6;
                            type_init_value = false;
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
                            _typeBoxSet = true;
                            _typeBoxVisible = 1.0;
                            _character = value;
                            type_id = 7;
                            type_init_value = false;
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
                            _typeBoxVisible = 0.0;
                            _character = value;
                            type_init_value = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
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
                AnimatedOpacity(
                  opacity: _typeBoxVisible,
                  duration: const Duration(seconds: 1),
                  child: Visibility(
                    visible: _typeBoxSet,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: input_title(tr("clock.create.type"), true),
                    ),
                  ),
                  onEnd: () {
                    if (_typeBoxVisible == 0) {
                      setState(() {
                        _typeBoxSet = false;
                      });
                    }
                  },
                ),
                //主類別title
                AnimatedOpacity(
                  opacity: _typeBoxVisible,
                  duration: const Duration(seconds: 1),
                  child: Visibility(
                    visible: _typeBoxSet,
                    child: Column(
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.only(top: 5)),
                        ClockType(
                          allType: allType,
                          type_id: type_id,
                          callback: callback,
                          type_init_value: type_init_value,
                        ),
                      ],
                    ),
                  ),
                  onEnd: () {
                    if (_typeBoxVisible == 0) {
                      setState(() {
                        _typeBoxSet = false;
                      });
                    }
                  },
                ),
                //主類別select
                AnimatedOpacity(
                  opacity: _typeBoxVisible,
                  duration: const Duration(seconds: 1),
                  child: Visibility(
                    visible: _typeBoxSet,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: input_title(tr("clock.create.child_type"), true),
                    ),
                  ),
                  onEnd: () {
                    if (_typeBoxVisible == 0) {
                      setState(() {
                        _typeBoxSet = false;
                      });
                    }
                  },
                ),
                //子類別title
                AnimatedOpacity(
                  opacity: _typeBoxVisible,
                  duration: const Duration(seconds: 1),
                  child: Visibility(
                    visible: _typeBoxSet,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: ClockChildType(
                            allType: allType,
                            type_id: type_id,
                            parent_id: parent_id,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onEnd: () {
                    if (_typeBoxVisible == 0) {
                      setState(() {
                        _typeBoxSet = false;
                      });
                    }
                  },
                ),
                //子類別select
                const Padding(padding: EdgeInsets.only(top: 10)),
                input_title(tr("clock.create.depart_time"), true),
                TextFormField(
                  controller: _depart,
                  decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: const OutlineInputBorder(),
                      labelText: _input,
                      labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          DatePicker.showDateTimePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(2018, 3, 5),
                              maxTime: DateTime(2019, 6, 7), onConfirm: (date) {
                                _depart.text =
                                    DateFormat('yyyy-MM-dd kk:mm').format(date);
                              },
                              currentTime: DateTime.now(),
                              locale: LocaleType.zh);
                        },
                        icon: Icon(Ionicons.calendar_outline),
                      )),
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                input_title(tr("clock.create.start_time"), true),
                TextFormField(
                  controller: _start,
                  decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: const OutlineInputBorder(),
                      labelText: _input,
                      labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          DatePicker.showDateTimePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(2018, 3, 5),
                              maxTime: DateTime(2019, 6, 7), onConfirm: (date) {
                            _start.text =
                                DateFormat('yyyy-MM-dd kk:mm').format(date);
                          },
                              currentTime: DateTime.now(),
                              locale: LocaleType.zh);
                        },
                        icon: Icon(Ionicons.calendar_outline),
                      )),
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                input_title(tr("clock.create.end_time"), true),
                TextFormField(
                  controller: _end,
                  decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: const OutlineInputBorder(),
                      labelText: _input,
                      labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          DatePicker.showDateTimePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(2018, 3, 5),
                              maxTime: DateTime(2019, 6, 7), onConfirm: (date) {
                            _end.text =
                                DateFormat('yyyy-MM-dd kk:mm').format(date);
                          },
                              currentTime: DateTime.now(),
                              locale: LocaleType.zh);
                        },
                        icon: Icon(Ionicons.calendar_outline),
                      )),
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
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
                            labelText: tr("clock.create.hours"),
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ClipPath(
                      child: Card(
                        color: MetronicTheme.light_primary,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: IconButton(
                          onPressed: () {
                            countHours();
                            print('123');
                          },
                          icon: Icon(Ionicons.calculator_outline),
                          color: MetronicTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
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
                            labelText: tr("clock.create.hours"),
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
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
                            labelText: tr("clock.create.hours"),
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                input_title(tr("clock.create.context"), true),
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: TextFormField(
                          controller: clock_context,
                          maxLines: 5,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 15),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: const OutlineInputBorder(),
                            labelText: tr("clock.create.context_labelText"),
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                            color:MetronicTheme.dark),
                        label: const Text(
                          '返回',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: MetronicTheme.dark,
                              fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: MetronicTheme.light_dark,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          subimt_clock();
                        },
                        icon:
                            Icon(Ionicons.pencil, color: MetronicTheme.success),
                        label: const Text(
                          '儲存草稿',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: MetronicTheme.success,
                              fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: MetronicTheme.light_success,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Ionicons.checkmark_circle,
                            color: MetronicTheme.info),
                        label: const Text(
                          '送審',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: MetronicTheme.info,
                              fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: MetronicTheme.light_info,
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
    );
  }

  callback(newAbc) {
    setState(() {
      parent_id = newAbc;
      type_init_value = true;
    });
  }

  countHours() async {
    dio.options.headers['Authorization'] =
        'Bearer 515|eM1k7UlR33lFFJLFhtm6exPkIaLcXXrJk2qWoNh9'; // TODO: 統一設定
    Response res = await dio.post(
      'http://10.0.2.2/api/countHoursAPI', // TODO: URL 放至 env 相關設定
      data: {
        'start_time': '2023-01-01 15:00:00', //_start.text
        'end_time': '2023-01-01 16:00:00', //_end.text
      },
    );

    if (res.statusCode == 200 && res.data != null) {
      _departHour.text = res.data['hours']['trafficHours'] + '小時';
      _totalHours.text = res.data['hours']['totalHours'] + '小時';
      _worksHours.text = res.data['hours']['worksHours'] + '小時';
    }
    //todo:驗證失敗
  }

  subimt_clock() async {
    dio.options.headers['Authorization'] =
    'Bearer 515|eM1k7UlR33lFFJLFhtm6exPkIaLcXXrJk2qWoNh9'; // TODO: 統一設定
    Response res = await dio.post(
      'http://10.0.2.2/api/storeClockAPI', // TODO: URL 放至 env 相關設定
      data: {
        'context': clock_context.text,
        'type': parent_id,
        'clock_type': parent_id,
        'departTime': _depart.text,
        'startTime': _start.text, //_start.text
        'endTime': _end.text, //_end.text
        'total_hours': _totalHours.text,
      },
    );
  }
}
