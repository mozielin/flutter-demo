import 'dart:math';

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
  clock_card() {
    return ClipPath(
      clipper: HoleClipper(),
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(context).colorScheme.shadow,
        color: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: ListTile(
          onTap: () {
            Navigator.pushNamed(context, '/clock_demo');
          },
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Ink(
                    padding: EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: CircleBorder(),
                    ),
                    child: Icon(Ionicons.construct,
                        color: Theme.of(context).textTheme.bodySmall!.color),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('T20221203001'),
                      Text('C202010001-01')
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(left: 20)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Oct.20',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.purple[50],
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: Text(
                            '審核中',
                            style: TextStyle(
                              color: Colors.purple[300],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Divider(
                height: 20,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
              Text(
                '4 H',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[Text('出發時間'), Text('09:00')],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('1 h 30 m'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(
                            Ionicons.car,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                          Text('--------'),
                          Icon(
                            Ionicons.git_commit,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                          Text('--------'),
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
                    children: <Widget>[Text('到場時間'), Text('10:30')],
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[Text('開始時間'), Text('10:30')],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('2 h 30 m'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(
                            Ionicons.build,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                          Text('--------'),
                          Icon(
                            Ionicons.git_commit,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                          Text('--------'),
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
                    children: <Widget>[Text('結束時間'), Text('13:00')],
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(5)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Clock List Demo',
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
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: CircleBorder(),
            ),
            child: SizedBox(
                height: 35.0,
                width: 35.0,
                child: IconButton(
                  padding: EdgeInsets.all(4),
                  icon: Image.asset(
                    'assets/img/default_user_avatar.png',
                    fit: BoxFit.cover,
                  ),
                  tooltip: '使用者資訊',
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('使用者資訊畫面')));
                  },
                )),
          ),
        ],
      ),
      body: Material(
        color: Theme.of(context).colorScheme.background,
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              ClipPath(
                clipper: HoleClipper(),
                child: clock_card(),
              ),
              clock_card(),
              clock_card(),
              clock_card(),
              clock_card(),
              clock_card(),
              clock_card(),
              clock_card(),
              clock_card(),
              clock_card(),
              clock_card(),
              clock_card(),
              Text(
                '-------------- 載入更多資訊 --------------',
                textAlign: TextAlign.center,
              ),
              Text(
                '-------------- 已經達最底部 --------------',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )), // This trailing comma makes auto-formatting nicer for build methods.
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
        Radius.circular(5),
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
    var a_left = offset.dx + size.width - 15;
    var a_top = offset.dy;
    var a_right = a_left + d;
    var a_bottom = a_top + d;
    path.addOval(Rect.fromLTRB(a_left, a_top, a_right, a_bottom));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
