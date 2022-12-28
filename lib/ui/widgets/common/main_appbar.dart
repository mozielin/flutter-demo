// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({Key? key, required this.title, required this.appBar})
      : super(key: key);
  final AppBar appBar;
  final title;

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      leading: IconButton(
        icon: Icon(
          Ionicons.arrow_back_outline,
          color: Theme.of(context).textTheme.bodySmall!.color,
        ),
        tooltip: tr("appbar.previous_page"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        title,
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
          tooltip: tr("appbar.notification"),
          onPressed: null,
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
                tooltip: tr("appbar.user_info"),
                onPressed: null,
              )),
        ),
        const Padding(padding: EdgeInsets.only(right: 10)),
      ],
    );
    ;
  }
}
