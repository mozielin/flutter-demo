import 'dart:math';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hws_app/cubit/bottom_nav_cubit.dart';
import 'package:ionicons/ionicons.dart';
import '../../models/user.dart';

class ClockDemo extends StatefulWidget {
  const ClockDemo({super.key});

  @override
  State<ClockDemo> createState() => _ClockDemoState();
}

class _ClockDemoState extends State<ClockDemo> {
  final Dio dio = Dio();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool hideAdvanceSearch = true;
  bool showbtn = false;
  bool is_bottom = false;
  bool _load = false;
  bool _loading = true;
  int skip = 0;
  int take = 20;
  List items = [];
  final GlobalKey<FormFieldState> _statusKey = GlobalKey<FormFieldState>();
  var _status = '';

  getStatusLabel(status) {
    var text = '';
    var textColor;
    var bgColor;

    switch (status) {
      case 1:
        text = '草稿';
        textColor = const Color(0xFF1BC5BD);
        bgColor = const Color(0xFFC9F7F5);
        break;
      case 2:
        text = '待主管審核';
        textColor = const Color(0xFF8950FC);
        bgColor = const Color(0xFFEEE5FF);
        break;
      case 3:
        text = '待專案 Owner 審核';
        textColor = const Color(0xFF8950FC);
        bgColor = const Color(0xFFEEE5FF);
        break;
      case 4:
        text = '待業務審核';
        textColor = const Color(0xFF8950FC);
        bgColor = const Color(0xFFEEE5FF);
        break;
      case 5:
        text = '審核完成';
        textColor = const Color(0xFF8950FC);
        bgColor = const Color(0xFFEEE5FF);
        break;
      case 6:
        text = '駁回';
        textColor = const Color(0xFFF64E60);
        bgColor = const Color(0xFFFFE2E5);
        break;
      case 7:
        text = '未轉入';
        textColor = const Color(0xFFFFA800);
        bgColor = const Color(0xFFFFF4DE);
        break;
      case 8:
        text = '完成';
        textColor = const Color(0xFF3699FF);
        bgColor = const Color(0xFFE1F0FF);
        break;
      case 9:
        text = '待轉入系統';
        textColor = const Color(0xFF8950FC);
        bgColor = const Color(0xFFEEE5FF);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bgColor,
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  clock_card(data) {
    // 參數帶入
    var clockId = data['id'];
    var documentNumber = data['source_no'];
    var caseNo = data['sap_wbs'] ?? '無 Case 報工';
    var status = data['status'];
    var createDate =
        DateFormat('MMM.d').format(DateTime.tryParse(data['depart_time'])!);
    var departDatetime = DateTime.tryParse(data['depart_time'])!;
    var startDatetime = DateTime.tryParse(data['start_time'])!;
    var endDatetime = DateTime.tryParse(data['end_time'])!;

    // 時間計算
    var departTime = DateFormat('HH:mm').format(departDatetime);
    var startTime = DateFormat('HH:mm').format(startDatetime);
    var endTime = DateFormat('HH:mm').format(endDatetime);
    var startDiffTime = startDatetime.difference(departDatetime);
    var startDiffHour = startDiffTime.inHours;
    var startDiffMin = startDiffTime.inMinutes - startDiffTime.inHours * 60;
    var endDiffTime = endDatetime.difference(startDatetime);
    var endDiffHour = endDiffTime.inHours;
    var endDiffMin = endDiffTime.inMinutes - endDiffTime.inHours * 60;
    var totalDiffTime = endDatetime.difference(departDatetime);
    var totalDiffHour = totalDiffTime.inHours;
    var totalDiffMin = totalDiffTime.inMinutes - totalDiffTime.inHours * 60;

    return ClipPath(
      clipper: HoleClipper(),
      child: Card(
        shadowColor: Theme.of(context).colorScheme.shadow,
        color: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: ListTile(
          onTap: () {
            Navigator.pushNamed(context, '/clock/$clockId');
          },
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Padding(padding: EdgeInsets.all(5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Ink(
                    padding: const EdgeInsets.all(10),
                    decoration: const ShapeDecoration(
                      color: Colors.white,
                      shape: CircleBorder(),
                    ),
                    child: Icon(Ionicons.construct,
                        color: Theme.of(context).textTheme.bodySmall!.color),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      (documentNumber != null)
                          ? Text('$documentNumber')
                          : Container(),
                      Text('$caseNo')
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(left: 20)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        createDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      getStatusLabel(status),
                    ],
                  ),
                ],
              ),
              Divider(
                height: 20,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
              Text(
                '$totalDiffHour h $totalDiffMin m',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[const Text('出發時間'), Text(departTime)],
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
                    children: <Widget>[const Text('到場時間'), Text(startTime)],
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[const Text('開始時間'), Text(startTime)],
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
                    children: <Widget>[const Text('結束時間'), Text(endTime)],
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(5)),
            ],
          ),
        ),
      ),
    );
  }

  getClock(bool clear) async {
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
        Response res = await dio.post(
          'http://10.0.2.2/api/getClocks',
          data: {
            'enumber': 'HW-M54',
            'skip': skip,
            'take': take,
            'fuzzy_search': _searchController.text,
            'status': _status,
          },
        );

        if (res.statusCode == 200 && res.data != null) {
          setState(() {
            if (res.data['clocks'].length < take) {
              is_bottom = true;
            }

            for (var each in res.data['clocks']) {
              items.add(clock_card(each));
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
    } on DioError catch (e) {
      setState(() {
        _load = false;
      });
      rethrow;
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

  Future<void> _pullToRefresh() async {
    setState(() {
      getClock(true);
    });
    return;
  }

  @override
  void initState() {
    scrollController.addListener(() {
      double showoffset =
          10.0; //Back to top botton will show on scroll offset 10.0

      if (scrollController.offset > showoffset) {
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
        getClock(false); // 滑至底部 Load more
      }
    });

    getClock(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _pullToRefresh,
      child: Scaffold(
        floatingActionButton: AnimatedOpacity(
          duration: const Duration(milliseconds: 250), //show/hide animation
          opacity: showbtn ? 1.0 : 0.0, //set obacity to 1 on visible, or hide
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
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          leading: IconButton(
            icon: Icon(
              Ionicons.arrow_back_outline,
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
            tooltip: '上一頁',
            onPressed: () {
              //點擊執行換頁
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            '報工列表',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall!.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Ionicons.notifications_outline,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
              tooltip: '通知',
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('通知畫面')));
              },
            ),
            Ink(
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: CircleBorder(),
              ),
              child: SizedBox(
                  height: 35.0,
                  width: 35.0,
                  child: IconButton(
                    padding: const EdgeInsets.all(4),
                    icon: Image.asset(
                      'assets/img/default_user_avatar.png',
                      fit: BoxFit.cover,
                    ),
                    tooltip: '使用者資訊',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('使用者資訊畫面')));
                    },
                  )),
            ),
            const Padding(padding: EdgeInsets.only(right: 10)),
          ],
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
                          Text(
                            '進階搜尋',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: DropdownButtonFormField(
                              key: _statusKey,
                              icon: Icon(
                                Ionicons.caret_down_outline,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color,
                              ),
                              hint: Text('請選擇狀態'),
                              value: null,
                              items: [
                                DropdownMenuItem(child: Text('草稿'), value: '1'),
                                DropdownMenuItem(
                                    child: Text('待主管審核'), value: '2'),
                                DropdownMenuItem(child: Text('待專案 Owner 審核'), value: '3'),
                                DropdownMenuItem(child: Text('待業務審核'), value: '4'),
                                DropdownMenuItem(child: Text('審核完成'), value: '5'),
                                DropdownMenuItem(child: Text('駁回'), value: '6'),
                                DropdownMenuItem(child: Text('未轉入'), value: '7'),
                                DropdownMenuItem(child: Text('完成'), value: '8'),
                                DropdownMenuItem(child: Text('待轉入系統'), value: '9'),
                              ],
                              onChanged: (String? value) {
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
                              labelText: '搜尋',
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
                          color: Color(0xFFFFE2E5),
                        ),
                        child: IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _status = '';
                            _statusKey.currentState!.reset();
                            getClock(true);
                          },
                          icon: const Icon(
                            Ionicons.trash,
                            color: Color(0xFFF64E60),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 6)),
                      Ink(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Color(0xFFC9F7F5),
                        ),
                        child: IconButton(
                          onPressed: () {
                            getClock(true);
                          },
                          icon: const Icon(
                            Ionicons.search,
                            color: Color(0xFF1BC5BD),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 6)),
                      Ink(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          color: Colors.grey[400],
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
                            color: Colors.black,
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
                      return items[index];
                    },
                  ),
                  _load
                      ? Text(
                          is_bottom
                              ? '-------------- 已經達最底部 --------------'
                              : '-------------- 載入更多資訊 --------------',
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          _loading ? '資料查詢中，請稍候...' : '查詢失敗，請聯繫 55032-資訊部-開發組！',
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

class HoleClipper extends CustomClipper<Path> {
  final Offset offset;
  final double holeSize;

  HoleClipper({this.offset = const Offset(0, 0.285), this.holeSize = 20});

  @override
  Path getClip(Size size) {
    Path circlePath = Path();
    circlePath.addRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(5),
      ),
    );

    double w = size.width;
    double h = size.height;
    Offset offsetXY = Offset(offset.dx * w, offset.dy * h);
    double d = holeSize;
    _getHold(circlePath, 1, d, offsetXY, size);
    circlePath.fillType = PathFillType.evenOdd;
    return circlePath;
  }

  void _getHold(Path path, int count, double d, Offset offset, size) {
    // 左耳朵
    var left = offset.dx - 5;
    var top = offset.dy;
    var right = left + d;
    var bottom = top + d;
    path.addOval(Rect.fromLTRB(left, top, right, bottom));
    // 右耳朵
    var aLeft = offset.dx + size.width - 15;
    var aTop = offset.dy;
    var aRight = aLeft + d;
    var aBottom = aTop + d;
    path.addOval(Rect.fromLTRB(aLeft, aTop, aRight, aBottom));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
