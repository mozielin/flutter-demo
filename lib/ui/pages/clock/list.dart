// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, must_be_immutable, camel_case_types, use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hws_app/config/theme.dart';
import 'package:hws_app/global_data.dart';
import 'package:hws_app/service/ClockInfo.dart';
import 'package:ionicons/ionicons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uiblock/uiblock.dart';
import 'package:uuid/uuid.dart';
import '../../../config/setting.dart';
import '../../../cubit/user_cubit.dart';
import '../../../service/sync.dart';
import '../../widgets/alert/icons/error_icon.dart';
import '../../widgets/alert/icons/success_icon.dart';
import '../../widgets/alert/icons/warning_icon.dart';
import '../../widgets/alert/styles.dart';
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
  String _status = '';
  bool hideAdvanceSearch = true;
  bool showbtn = false;
  bool is_bottom = false;
  bool _load = false;
  bool _loading = true;
  bool _canLoad = true;
  int skip = 0;
  int take = 20;
  List items = [];
  List images = [];

  getStatusLabel(status) {
    var text = '';
    var textColor;
    var bgColor;

    switch (status) {
      case '1':
        text = tr('clock.status.draft');
        textColor = Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : MetronicTheme.success;
        bgColor = Theme.of(context).brightness == Brightness.dark
                    ? MetronicTheme.light_dark
                    : MetronicTheme.light_success;
        break;
      case '2':
      case '3':
      case '4':
        text = tr('clock.status.verify');
        textColor = Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : MetronicTheme.info;
        bgColor = Theme.of(context).brightness == Brightness.dark
                    ? MetronicTheme.light_dark
                    : MetronicTheme.light_info;
        break;
      ///通通改為只顯示待審核
      // case '3':
      //   text = tr("clock.status.verify_owner");
      //   textColor = MetronicTheme.info;
      //   bgColor = MetronicTheme.light_info;
      //   break;
      // case '4':
      //   text = tr('clock.status.verify_sales');
      //   textColor = MetronicTheme.info;
      //   bgColor = MetronicTheme.light_info;
      //   break;
      case '5':
        text = tr('clock.status.done');
        textColor = Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : MetronicTheme.primary;
        bgColor = Theme.of(context).brightness == Brightness.dark
                    ? MetronicTheme.light_dark
                    : MetronicTheme.light_primary;
        break;
      case '6':
        text = tr('clock.status.reject');
        textColor = Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : MetronicTheme.danger;
        bgColor = Theme.of(context).brightness == Brightness.dark
                    ? MetronicTheme.light_dark
                    : MetronicTheme.light_danger;
        break;
      case '7':
        text = tr('clock.status.not_save_sap');
        textColor = Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : MetronicTheme.warning;
        bgColor = Theme.of(context).brightness == Brightness.dark
                    ? MetronicTheme.light_dark
                    : MetronicTheme.light_warning;
        break;
      case '8':
        text = tr('clock.status.not_save_crm');
        textColor = Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : MetronicTheme.warning;
        bgColor = Theme.of(context).brightness == Brightness.dark
                    ? MetronicTheme.light_dark
                    : MetronicTheme.light_warning;
        break;
      case '9':
        text = tr('clock.status.not_save_hws');
        textColor = Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : MetronicTheme.warning;
        bgColor = Theme.of(context).brightness == Brightness.dark
                    ? MetronicTheme.light_dark
                    : MetronicTheme.light_warning;
        break;
      case '10':
        text = tr('clock.status.sync_failed');
        textColor = Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : MetronicTheme.danger;
        bgColor = Theme.of(context).brightness == Brightness.dark
            ? MetronicTheme.light_dark
            : MetronicTheme.light_danger;
        break;

      case '11':
        text = tr('clock.status.bpm_failed');
        textColor = Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : MetronicTheme.danger;
        bgColor = Theme.of(context).brightness == Brightness.dark
            ? MetronicTheme.light_dark
            : MetronicTheme.light_danger;
        break;
    }

    return StatusLabel(title: text, color: textColor, bg_color: bgColor);
  }

  ///Show Card Widget
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ///刪除
                    if(data.status == '1' && data.sync_status != '3')
                      FloatingActionButton(
                      onPressed: () {
                        //Navigator.of(context).pop();
                        Alert(
                          context: context,
                          style: AlertStyles().warningStyle(context),
                          image: const WarningIcon(),
                          title: tr('clock.alerts.warning_delete_clock'),
                          desc: tr('clock.alerts.clock_delete'),
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
                                ///刪除報工資料
                                ClockInfo().deleteClock(data.id).then((res){
                                  if(res) {
                                    //Navigator.of(context).pop();
                                    Alert(
                                      context: context,
                                      style: AlertStyles().successStyle(context),
                                      image: const SuccessIcon(),
                                      title: tr('alerts.delete_success'),
                                      desc: tr('alerts.list_refresh'),
                                      buttons: [
                                        AlertStyles().getDoneButton(context, '/clock_list'),
                                      ],
                                    ).show();
                                  }else{
                                    Alert(
                                      context: context,
                                      style: AlertStyles().dangerStyle(context),
                                      image: const ErrorIcon(),
                                      title: tr('alerts.confirm_error'),
                                      desc: tr('alerts.something_wrong'),
                                      buttons: [
                                        AlertStyles().getCancelButton(context),
                                      ],
                                    ).show();
                                  }
                                });
                              },
                            ),
                          ],
                        ).show();
                      },
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.surface
                          : MetronicTheme.light_danger,
                      child: const Icon(
                        Ionicons.trash,
                        color:
                            MetronicTheme.danger,
                      ),
                    ),

                    ///返回列表
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.surface
                          : MetronicTheme.light_dark,
                      child: Icon(
                        Ionicons.close_outline,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).textTheme.titleLarge!.color
                            : MetronicTheme.dark,
                      ),
                    ),

                    ///編輯
                    if((data.status == '1' || data.status == '6') && data.sync_status != '3')
                      FloatingActionButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/create_clock', arguments: {'type': data.case_no == '' ? 'no_case' : 'has_case', 'data': data});
                      },
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.surface
                          : MetronicTheme.light_success,
                      child: const Icon(
                        Ionicons.pencil,
                        color: MetronicTheme.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  ///List Card Widget
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
    var documentNumber = data.source_no;
    var caseNo = data.case_no != '' ? data.case_no : tr("clock.card.no_case_number");
    var status = data.status;
    var departDatetime = DateTime.tryParse(data.depart_time == '' ? data.start_time : data.depart_time)!;
    var startDatetime = DateTime.tryParse(data.start_time)!;
    var endDatetime = DateTime.tryParse(data.end_time)!;
    var traffic_hours = data.traffic_hours;
    var worked_hours = data.worked_hours;
    var total_hours = data.total_hours;
    var createDate = '${DateFormat('M/d').format(departDatetime)}(${weekday[departDatetime.weekday]})';
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
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        child: ListTile(
          onTap: () {
            if (index != null) {
              images = jsonDecode(data.images);
              clock_dialog(items[index]);
            }
          },
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Padding(padding: EdgeInsets.all(5)),
              Row(
                children: <Widget>[
                  ///小卡左小圓圖
                  Expanded(
                    flex: 1,
                    child: Ink(
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        color: MetronicTheme.light_dark,
                        shape: CircleBorder(),
                      ),
                      child: Icon(
                          data.sync_status == '2' ? Ionicons.cloud_done : Ionicons.cloud_offline
                          ,color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.bodySmall!.color),
                    ),
                  ),
                  ///小卡case no
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          (documentNumber != '') ? Text('$documentNumber') : Container(),
                          Text('$caseNo'),
                          Text('Verify: ${data.is_verify}'),
                          Text('ID: ${data.id}'),
                          Text('sale_Type: ${data.sale_type}'),
                        ],
                      ),
                    ),
                  ),
                  ///最右側status label 跟時間
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:[
                        data.is_verify == '-1' ? getStatusLabel('11') : data.sync_failed == '' ? getStatusLabel(status) : getStatusLabel('10'),
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
                          children: <Widget>[Text(tr("clock.card.depart_time")), Text(departTime)],
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
                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                ),
                                const Text('--------'),
                                Icon(
                                  Ionicons.git_commit,
                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                ),
                                const Text('--------'),
                                Icon(
                                  Ionicons.location,
                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                ),
                              ],
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[Text(tr("clock.card.arrive_time")), Text(startTime)],
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.all(5)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[Text(tr("clock.card.start_time")), Text(startTime)],
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
                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                ),
                                const Text('--------'),
                                Icon(
                                  Ionicons.git_commit,
                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                ),
                                const Text('--------'),
                                Icon(
                                  Ionicons.checkmark_circle,
                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                ),
                              ],
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[Text(tr("clock.card.end_time")), Text(endTime)],
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

  ///List Card detail
  clock_detail(data) {
    // 參數帶入
    var clock_context = data.context;

    return Column(
      children: [
        if(data.sync_failed != '')
          getSyncFailed(data.sync_failed),
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
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        child: InkWell(
                          onTap: () {
                            NavigatorState nav = Navigator.of(context);
                            GlobalData.of(context)?.photo_file_base64_title = tr('clock.card.file');
                            GlobalData.of(context)?.photo_file_base64 = images[index];
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

  getClocks(bool clear) async {
    List clockList = [];
    int skipCount = 0;
    int count = 0;
    bool filterStatus = true;
    bool filterFuzzySearch = true;

    try {
      if (clear) {
        /// 是否清空
        setState(() {
          _canLoad = true;
          is_bottom = false;
          skip = 0;
          items = [];
        });
      }

      if (!_canLoad) return;

      if (!is_bottom) {
        List hiveClocks = await ClockInfo().GetClock();

        /// 資料篩選
        List clocks = hiveClocks.where((element) {
          if (_status != '') {
            filterStatus = (element.status == _status);
          }

          if (_searchController.text != '') {
            filterFuzzySearch = element.case_no.contains(_searchController.text);
          }

          ///排除已刪除資料
          filterStatus = (element.sync_status != '3');

          return filterStatus && filterFuzzySearch;
        }).toList();

        clocks.sort((b, a) => a.depart_time.compareTo(b.depart_time));

        for (var data in clocks) {
          if (skipCount == skip) {
            if (count == take) {
              break;
            } else {
              clockList.add(data);
              count++;
            }
          } else {
            skipCount++;
          }
        }

        setState(() {
          if (clockList.length < take) is_bottom = true;
          items.addAll(clockList);
          skip += take;
          _load = true;
          _canLoad = true;
        });
      }
    } catch (e) {
      setState(() {
        _load = false;
        _canLoad = true;
      });
      rethrow;
    }

    if (mounted) {
      setState(() {
        _loading = false;
        _canLoad = true;
      });
    }
  }

  Future<void> _pullToRefresh() async {
    setState(() {
      var user = BlocProvider.of<UserCubit>(context).state;
      SyncService().uploadClockData(user.token).then((result){
        ClockInfo().SyncClock(user.token, user.enumber).then((result){
          getClocks(true);
        });
      });
    });
    return;
  }

  ///上傳失敗原因文字
  getSyncFailed(sync_failed){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('clock.card.sync_failed_title'),
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
          sync_failed,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall!.color,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 20),
        ),
      ],
    );
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
        setState(() {
          _canLoad = false;
        });
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
          isPop: false,
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
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Column(
                        children: <Widget>[
                          const Padding(padding: EdgeInsets.only(top: 5)),
                          Text(
                            tr("search.advance_search"),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: DropdownButtonFormField(
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              key: _statusKey,
                              icon: Icon(
                                Ionicons.caret_down_outline,
                                color: Theme.of(context).textTheme.bodySmall!.color,
                              ),
                              hint: Text(
                                tr("search.hint.status"),
                                style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                              ),
                              onChanged: (value) async {
                                if (value != null) {
                                  _status = value;
                                }
                                await getClocks(true);
                              },
                              value: _status == '' ? null : _status,
                              items: [
                                DropdownMenuItem(value: '1', child: getStatusLabel('1')),
                                DropdownMenuItem(value: '2', child: getStatusLabel('2')),
                                DropdownMenuItem(value: '3', child: getStatusLabel('3')),
                                DropdownMenuItem(value: '4', child: getStatusLabel('4')),
                                DropdownMenuItem(value: '5', child: getStatusLabel('5')),
                                DropdownMenuItem(value: '6', child: getStatusLabel('6')),
                                DropdownMenuItem(value: '7', child: getStatusLabel('7')),
                                // DropdownMenuItem(
                                //     value: '8', child: getStatusLabel('8')),
                                DropdownMenuItem(value: '9', child: getStatusLabel('9')),
                              ],
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: const OutlineInputBorder(),
                              labelText: tr("search.search"),
                              labelStyle: TextStyle(
                                color: Theme.of(context).textTheme.bodySmall!.color,
                              ),
                              suffixIcon: IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onPressed: _searchController.clear,
                                icon: Icon(
                                  Ionicons.close,
                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 6)),
                      Ink(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.surface
                              : MetronicTheme.light_danger,
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
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.surface
                              : MetronicTheme.light_success,
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
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.surface
                              :MetronicTheme.light_dark,
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(
                              () {
                                hideAdvanceSearch = hideAdvanceSearch ? false : true;
                              },
                            );
                          },
                          icon: Icon(
                            Ionicons.options,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).textTheme.titleLarge!.color
                                : MetronicTheme.dark,
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
                              : tr('list.query_failed_contact_system_administrator'),
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
