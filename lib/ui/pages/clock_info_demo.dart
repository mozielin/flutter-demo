import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hws_app/cubit/bottom_nav_cubit.dart';
import 'package:hws_app/cubit/user_cubit.dart';
import 'package:hws_app/service/ClockInfo.dart';
import 'package:ionicons/ionicons.dart';

import '../../models/user.dart';

class ClockInfoDemo extends StatefulWidget {
  const ClockInfoDemo({super.key});

  @override
  State<ClockInfoDemo> createState() => _ClockInfoDemoState();
}

class _ClockInfoDemoState extends State<ClockInfoDemo> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await ClockInfo().SyncClock(
                        BlocProvider.of<UserCubit>(context).state.token);
                  },
                  icon: Icon(Ionicons.server_outline,
                      color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'SyncClock',
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
                    List clocks = await ClockInfo().GetClock();
                    for (var data in clocks) {
                      print(data.clocking_no);
                    }
                  },
                  icon: Icon(Ionicons.server_outline,
                      color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'GetClock',
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
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
