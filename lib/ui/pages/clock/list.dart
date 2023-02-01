// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, must_be_immutable, camel_case_types, use_build_context_synchronously

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hws_app/config/theme.dart';
import 'package:hws_app/global_data.dart';
import 'package:ionicons/ionicons.dart';
import 'package:uiblock/uiblock.dart';
import '../../widgets/clock/card_hole_clipper.dart';
import '../../widgets/common/status_label.dart';
import '../../widgets/common/main_appbar.dart';

class ClockDemo extends StatefulWidget {
  const ClockDemo({super.key});

  @override
  State<ClockDemo> createState() => _ClockDemoState();
}

class _ClockDemoState extends State<ClockDemo> {
  final Dio dio = Dio();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ScrollController dialogController = ScrollController();
  final GlobalKey<FormFieldState> _statusKey = GlobalKey<FormFieldState>();
  var _status = '';
  bool hideAdvanceSearch = true;
  bool showbtn = false;
  bool is_bottom = false;
  bool _load = false;
  bool _loading = true;
  int skip = 0;
  int take = 20;
  List items = [];
  List images = [];

  getStatusLabel(status) {
    var text = '';
    var textColor;
    var bgColor;

    switch (status) {
      case 1:
        text = tr('clock.status.draft');
        textColor = MetronicTheme.success;
        bgColor = MetronicTheme.light_success;
        break;
      case 2:
        text = tr('clock.status.verify');
        textColor = MetronicTheme.info;
        bgColor = MetronicTheme.light_info;
        break;
      case 3:
        text = tr("clock.status.verify_owner");
        textColor = MetronicTheme.info;
        bgColor = MetronicTheme.light_info;
        break;
      case 4:
        text = tr('clock.status.verify_sales');
        textColor = MetronicTheme.info;
        bgColor = MetronicTheme.light_info;
        break;
      case 5:
        text = tr('clock.status.done');
        textColor = MetronicTheme.primary;
        bgColor = MetronicTheme.light_primary;
        break;
      case 6:
        text = tr('clock.status.reject');
        textColor = MetronicTheme.danger;
        bgColor = MetronicTheme.light_danger;
        break;
      case 7:
        text = tr('clock.status.not_save_sap');
        textColor = MetronicTheme.warning;
        bgColor = MetronicTheme.light_warning;
        break;
      case 8:
        text = tr('clock.status.not_save_crm');
        textColor = MetronicTheme.warning;
        bgColor = MetronicTheme.light_warning;
        break;
      case 9:
        text = tr('clock.status.not_save_hws');
        textColor = MetronicTheme.warning;
        bgColor = MetronicTheme.light_warning;
        break;
    }

    return StatusLabel(title: text, color: textColor, bg_color: bgColor);
  }

  clock_dialog(data) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(padding: EdgeInsets.all(25)),
                clock_card(null, data),
                const Padding(padding: EdgeInsets.all(5)),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  backgroundColor: MetronicTheme.light_dark,
                  child: const Icon(
                    Ionicons.close_outline,
                    color: MetronicTheme.dark,
                  ),
                ),
              ],
            ),
          );
        });
  }

  clock_detail(data) {
    // 參數帶入
    var clock_context = data['context'];
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tr('clock.card.context'),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall!.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              height: 20,
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
            Text(
              clock_context,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Text(
              tr('clock.card.file'),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall!.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              height: 20,
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
            (images.isNotEmpty)
                ? ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        shadowColor: Theme.of(context).colorScheme.shadow,
                        color: Theme.of(context).colorScheme.background,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: InkWell(
                          onTap: () {
                            NavigatorState nav = Navigator.of(context);
                            GlobalData.of(context)?.photo_file_base64_title =
                                tr('clock.card.file');
                            GlobalData.of(context)?.photo_file_base64 =
                                images[index];
                            nav.pushNamed('/photo_detail_base64');
                          },
                          child: Image.memory(
                            base64Decode(images[index]),
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  )
                : Text(
                    tr('alert.no_data'),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                  ),
            const Padding(padding: EdgeInsets.all(5)),
          ],
        )
      ],
    );
  }

  clock_card(index, data) {
    var weekday = [
      " ",
      tr('week.short.mon'),
      tr('week.short.tue'),
      tr('week.short.wed'),
      tr('week.short.thu'),
      tr('week.short.fri'),
      tr('week.short.sat'),
      tr('week.short.sun')
    ];
    // 參數帶入
    var clock_id = data['id'];
    var documentNumber = data['source_no'];
    var caseNo = data['case_no'] ?? tr("clock.card.no_case_number");
    var status = data['status'];

    var departDatetime = DateTime.tryParse(data['depart_time'])!;
    var startDatetime = DateTime.tryParse(data['start_time'])!;
    var endDatetime = DateTime.tryParse(data['end_time'])!;
    var traffic_hours = data['traffic_hours'];
    var worked_hours = data['worked_hours'];
    var total_hours = data['total_hours'];
    var createDate =
        '${DateFormat('M/d').format(departDatetime)}(${weekday[departDatetime.weekday]})';
    // 時間計算
    var departTime = DateFormat('HH:mm').format(departDatetime);
    var startTime = DateFormat('HH:mm').format(startDatetime);
    var endTime = DateFormat('HH:mm').format(endDatetime);
    var startDiffHour = traffic_hours ~/ 1;
    var startDiffMin = (traffic_hours % 1 * 60).toStringAsFixed(0);
    var endDiffHour = worked_hours ~/ 1;
    var endDiffMin = (worked_hours % 1 * 60).toStringAsFixed(0);
    var totalDiffHour = total_hours ~/ 1;
    var totalDiffMin = (total_hours % 1 * 60).toStringAsFixed(0);

    return ClipPath(
      clipper: HoleClipper(),
      child: Card(
        shadowColor: Theme.of(context).colorScheme.shadow,
        color: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: ListTile(
          onTap: () async {
            if (index != null) {
              await getClockImages(clock_id);
              clock_dialog(items[index]);
            }
          },
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Padding(padding: EdgeInsets.all(5)),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Ink(
                      padding: const EdgeInsets.all(10),
                      decoration: const ShapeDecoration(
                        color: Colors.white,
                        shape: CircleBorder(),
                      ),
                      child: Icon(Ionicons.construct,
                          color: Theme.of(context).textTheme.bodySmall!.color),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          (documentNumber != null)
                              ? Text('$documentNumber')
                              : Container(),
                          Text('$caseNo')
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        getStatusLabel(status),
                        Text(
                          createDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 20,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
              SizedBox(
                height: (index == null) ? 500 : 140,
                child: ListView(
                  controller: dialogController,
                  children: [
                    Text(
                      '$totalDiffHour h $totalDiffMin m',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(tr("clock.card.depart_time")),
                            Text(departTime)
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('$startDiffHour h $startDiffMin m'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Icon(
                                  Ionicons.car,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color,
                                ),
                                const Text('--------'),
                                Icon(
                                  Ionicons.git_commit,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color,
                                ),
                                const Text('--------'),
                                Icon(
                                  Ionicons.location,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color,
                                ),
                              ],
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(tr("clock.card.arrive_time")),
                            Text(startTime)
                          ],
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.all(5)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(tr("clock.card.start_time")),
                            Text(startTime)
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('$endDiffHour h $endDiffMin m'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Icon(
                                  Ionicons.build,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color,
                                ),
                                const Text('--------'),
                                Icon(
                                  Ionicons.git_commit,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color,
                                ),
                                const Text('--------'),
                                Icon(
                                  Ionicons.checkmark_circle,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color,
                                ),
                              ],
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(tr("clock.card.end_time")),
                            Text(endTime)
                          ],
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.all(5)),
                    (index == null) ? clock_detail(data) : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getClocks(bool clear) async {
    try {
      if (clear) {
        // 是否清空
        setState(() {
          is_bottom = false;
          skip = 0;
          items = [];
        });
      }

      if (!is_bottom) {
        dio.options.headers['Authorization'] =
            'Bearer 515|eM1k7UlR33lFFJLFhtm6exPkIaLcXXrJk2qWoNh9'; // TODO: 統一設定
        Response res = await dio.post(
          'http://10.0.2.2:81/api/getClocks', // TODO: URL 放至 env 相關設定
          data: {
            'enumber': 'HW-M54',
            'skip': skip,
            'take': take,
            'fuzzy_search': _searchController.text,
            'status': _status,
          },
        ).timeout(const Duration(seconds: 5));

        if (res.statusCode == 200 && res.data != null) {
          setState(() {
            if (res.data['clocks'].length < take) {
              is_bottom = true;
            }

            for (var each in res.data['clocks']) {
              items.add(each);
            }

            skip += take;
            _load = true;
          });
        } else {
          setState(() {
            _load = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _load = false;
      });
      rethrow;
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  getClockImages(clock_id) async {
    try {
      UIBlock.block(context);
      setState(() {
        images = [];
      });

      dio.options.headers['Authorization'] =
          'Bearer 515|eM1k7UlR33lFFJLFhtm6exPkIaLcXXrJk2qWoNh9'; // TODO: 統一設定
      Response res = await dio.post(
        'http://10.0.2.2:81/api/getClockImages', // TODO: URL 放至 env 相關設定
        data: {'clock_id': clock_id},
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 && res.data != null) {
        setState(() {
          for (var each in res.data['images']) {
            images.add(each['base64_path'].split('base64,')[1]);
          }
        });
      } else {
        setState(() {});
      }
    } catch (e) {
      setState(() {});
      rethrow;
    }

    if (mounted) {
      setState(() {});
    }
    UIBlock.unblock(context);
  }

  Future<void> _pullToRefresh() async {
    setState(() {
      getClocks(true);
    });
    return;
  }

  @override
  void initState() {
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

      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      if (maxScroll - currentScroll <= 0) {
        getClocks(false); // 滑至底部 Load more
      }
    });

    getClocks(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _pullToRefresh,
      child: Scaffold(
        floatingActionButton: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: showbtn ? 1.0 : 0.0,
          child: FloatingActionButton(
            onPressed: () {
              scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(
              Ionicons.arrow_up_outline,
              color: Colors.white,
            ),
          ),
        ),
        appBar: MainAppBar(
          title: tr("clock.appbar.list"),
          appBar: AppBar(),
        ),
        body: Material(
          color: Theme.of(context).colorScheme.background,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListView(
                controller: scrollController,
                children: <Widget>[
                  Offstage(
                    offstage: hideAdvanceSearch,
                    child: Card(
                      shadowColor: Theme.of(context).colorScheme.shadow,
                      color: Theme.of(context).colorScheme.surface,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Column(
                        children: <Widget>[
                          const Padding(padding: EdgeInsets.only(top: 5)),
                          Text(
                            tr("search.advance_search"),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: DropdownButtonFormField(
                              dropdownColor:
                                  Theme.of(context).colorScheme.surface,
                              key: _statusKey,
                              icon: Icon(
                                Ionicons.caret_down_outline,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color,
                              ),
                              hint: Text(
                                tr("search.hint.status"),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color),
                              ),
                              value: null,
                              items: [
                                DropdownMenuItem(
                                    value: '1', child: getStatusLabel(1)),
                                DropdownMenuItem(
                                    value: '2', child: getStatusLabel(2)),
                                DropdownMenuItem(
                                    value: '3', child: getStatusLabel(3)),
                                DropdownMenuItem(
                                    value: '4', child: getStatusLabel(4)),
                                DropdownMenuItem(
                                    value: '5', child: getStatusLabel(5)),
                                DropdownMenuItem(
                                    value: '6', child: getStatusLabel(6)),
                                DropdownMenuItem(
                                    value: '7', child: getStatusLabel(7)),
                                // DropdownMenuItem(
                                //     value: '8', child: getStatusLabel(8)),
                                DropdownMenuItem(
                                    value: '9', child: getStatusLabel(9)),
                              ],
                              onChanged: (value) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                setState(() {
                                  _status = value!;
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: const OutlineInputBorder(),
                              labelText: tr("search.search"),
                              labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color,
                              ),
                              suffixIcon: IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onPressed: _searchController.clear,
                                icon: Icon(
                                  Ionicons.close,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 6)),
                      Ink(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: MetronicTheme.light_danger,
                        ),
                        child: IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _status = '';
                            _statusKey.currentState!.reset();
                            FocusScope.of(context).requestFocus(FocusNode());
                            getClocks(true);
                          },
                          icon: const Icon(
                            Ionicons.trash,
                            color: MetronicTheme.danger,
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 6)),
                      Ink(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: MetronicTheme.light_success,
                        ),
                        child: IconButton(
                          onPressed: () {
                            getClocks(true);
                          },
                          icon: const Icon(
                            Ionicons.search,
                            color: MetronicTheme.success,
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 6)),
                      Ink(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: MetronicTheme.light_dark,
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(
                              () {
                                hideAdvanceSearch =
                                    hideAdvanceSearch ? false : true;
                              },
                            );
                          },
                          icon: const Icon(
                            Ionicons.options,
                            color: MetronicTheme.dark,
                          ),
                        ),
                      ),
                    ],
                  ), // 搜尋 UI
                  ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return clock_card(index, items[index]);
                    },
                  ),
                  _load
                      ? Text(
                          is_bottom
                              ? '-------------- ${tr('list.reached_bottom')} --------------'
                              : '-------------- ${tr('list.load_more')} --------------',
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          _loading
                              ? tr('list.data_query_plz_wait')
                              : tr(
                                  'list.query_failed_contact_system_administrator'),
                          textAlign: TextAlign.center,
                        )
                ],
              ),
            ),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
      ),
    );
  }
}
