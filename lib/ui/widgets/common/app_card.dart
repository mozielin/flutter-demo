// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AppCard extends StatelessWidget {
  AppCard({super.key,
    required this.appPath,
  });

  final appPath;
  var appIcon;
  var appName;

  getCardInfo() {
    switch (appPath) {
      case "clock_list":
        appIcon = Ionicons.time_outline;
        appName = tr('clock.appbar.list');
        break;
      case "api_demo":
        appIcon = Ionicons.paper_plane_outline;
        appName = 'API Demo';
        break;
      case "hive_demo":
        appIcon = Ionicons.server_outline;
        appName = 'Hive Demo';
        break;
      case "file_demo":
        appIcon = Ionicons.images_outline;
        appName = 'File Demo';
        break;
      default:
        appIcon = Ionicons.help_outline;
        appName = appPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    getCardInfo();
    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow,
      color: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/$appPath');
        },
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Icon(appIcon, color: Theme.of(context).colorScheme.primary),
            Text(
              appName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .apply(fontWeightDelta: 2, fontSizeDelta: -2),
            ),
          ],
        ),
      ),
    );
  }
}
