import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ClockType extends StatefulWidget {
  const ClockType(
      {Key? key,
      required this.allType,
      required this.attr_id,
      this.callback,
      this.type_init_value,
      this.has_case,
      this.parent_id})
      : super(key: key);
  final allType;
  final attr_id;
  final callback;
  final type_init_value;
  final has_case;
  final parent_id;

  @override
  State<ClockType> createState() => _ClockTypeState();
}

class _ClockTypeState extends State<ClockType> {
  late GlobalKey<FormFieldState> _statusKey = GlobalKey<FormFieldState>();
  var selected = null;

  List<DropdownMenuItem> getDynamicMenu(attr_id, has_case) {
    List<DropdownMenuItem> dynamicMenus = [];
    has_case = has_case == 'has_case' ? 1 : 2;
    if (widget.allType.isNotEmpty &&
        widget.attr_id != null &&
        attr_id != null) {
      widget.allType['$attr_id']['child'].forEach((k, v) {
        if (widget.allType['$attr_id']['has_case'] == has_case) {
          dynamicMenus.add(
            DropdownMenuItem(
                key: ValueKey(k), value: '$k', child: Text(v['name'])),
          );
        }
      });
    }
    return dynamicMenus;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type_init_value == false && _statusKey.currentState != null) {
      _statusKey.currentState!.reset();
    } else if (widget.parent_id != null) { //滾輪重build把選擇的值帶回來
      selected = widget.parent_id;
    }

    return DropdownButtonFormField(
      isExpanded: true,
      dropdownColor: Theme.of(context).colorScheme.surface,
      key: _statusKey,
      value: widget.type_init_value == false ? null : selected,
      icon: Icon(
        Ionicons.caret_down_outline,
        color: Theme.of(context).textTheme.bodySmall!.color,
      ),
      hint: Text(
        tr("search.hint.type"),
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
      ),
      items: getDynamicMenu(widget.attr_id, widget.has_case),
      onChanged: (value) {
        selected = value;
        widget.callback(value);
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
