import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class ClockChildType extends StatefulWidget {
  const ClockChildType(
      {Key? key,
      required this.allType,
      required this.type_id,
      required this.parent_id})
      : super(key: key);
  final allType;
  final type_id;
  final parent_id;

  @override
  State<ClockChildType> createState() => _ClockChildTypeState();
}

class _ClockChildTypeState extends State<ClockChildType> {
  // late final GlobalKey<FormFieldState> _statusKey = GlobalKey<FormFieldState>();
  List<DropdownMenuItem> getDynamicChildType(attr_id, parent_id) {
    List<DropdownMenuItem> dynamicMenus = [];
    if (parent_id != null) {
      widget.allType['$attr_id']['child'].forEach((k, v) {
        if (k == parent_id && v['child'] != null) {
            print('child');
            // _statusKey.currentState!.reset();
            v['child'].forEach((kk, vv){
              dynamicMenus.add(DropdownMenuItem(value: '$kk', child: Text('$vv')));
            });
        }
      });
    }
    return dynamicMenus;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      dropdownColor: Theme.of(context).colorScheme.surface,
      // key: _statusKey,
      icon: Icon(
        Ionicons.caret_down_outline,
        color: Theme.of(context).textTheme.bodySmall!.color,
      ),
      hint: Text(
        tr("search.hint.status"),
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
      ),
      value: null,
      items: getDynamicChildType(widget.type_id, widget.parent_id),
      onChanged: (value) {
        print('child_change');
        // FocusScope.of(context).requestFocus(FocusNode());
        // setState(() {
        // });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: const OutlineInputBorder(),
      ),
    );
    return Container();
  }
}
