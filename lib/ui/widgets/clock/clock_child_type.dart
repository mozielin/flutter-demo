import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class ClockChildType extends StatefulWidget {
  const ClockChildType({
    Key? key,
    required this.allType,
    required this.attr_id,
    required this.childCallback,
    required this.parent_id,
    required this.reset_child,
    this.child_id,
  }) : super(key: key);
  final allType;
  final attr_id;
  final parent_id;
  final childCallback;
  final reset_child;
  final child_id;

  @override
  State<ClockChildType> createState() => _ClockChildTypeState();
}

class _ClockChildTypeState extends State<ClockChildType> {
  late final GlobalKey<FormFieldState> _statusKeyChild =
      GlobalKey<FormFieldState>();
  var selected;

  List<DropdownMenuItem> getDynamicChildType(attr_id, parent_id) {
    List<DropdownMenuItem> dynamicMenus = [];
    if (_statusKeyChild.currentState != null && widget.reset_child == true) {
      _statusKeyChild.currentState!.reset();
    }

    if (parent_id != null) {
      widget.allType['$attr_id']['child'].forEach((k, v) {
        if (k == parent_id && v['child'] != null) {
          v['child'].forEach((kk, vv) {
            dynamicMenus
                .add(DropdownMenuItem(value: '$kk', child: Text('$vv')));
          });
        }
      });
    }
    return dynamicMenus;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child_id != null && widget.reset_child != true) {
      selected = widget.child_id;
    }
    return DropdownButtonFormField(
      isExpanded: true,
      dropdownColor: Theme.of(context).colorScheme.surface,
      key: _statusKeyChild,
      icon: Icon(
        Ionicons.caret_down_outline,
        color: Theme.of(context).textTheme.bodySmall!.color,
      ),
      hint: Text(
        tr("search.hint.sub_type"),
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
      ),
      value: widget.reset_child == true ? null : selected,
      items: getDynamicChildType(widget.attr_id, widget.parent_id),
      onChanged: (value) {
        widget.childCallback(value);
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
