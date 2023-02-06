import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ClockType extends StatefulWidget {
  const ClockType({Key? key, required this.allType, required this.attr_id,  this.callback, this.type_init_value})
      : super(key: key);
  final allType;
  final attr_id;
  final callback;
  final type_init_value;

  @override
  State<ClockType> createState() => _ClockTypeState();
}

class _ClockTypeState extends State<ClockType> {
  final GlobalKey<FormFieldState> _statusKey = GlobalKey<FormFieldState>();
  var selected = 0;
  List<DropdownMenuItem> getDynamicMenu(attr_id) {
    List<DropdownMenuItem> dynamicMenus = [];
    if (widget.allType.isNotEmpty && widget.attr_id != null && attr_id != null) {
      widget.allType['$attr_id']['child'].forEach((k, v) {
          dynamicMenus.add(DropdownMenuItem(key: ValueKey(k), value: '$k', child: Text(v['name'])),);
      });
    }
    return dynamicMenus;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type_init_value == false && _statusKey.currentState!= null) {
      _statusKey.currentState!.reset();
      setState(() {
        selected = 0;
      });
    }

    return DropdownButtonFormField(
      dropdownColor: Theme.of(context).colorScheme.surface,
      key: _statusKey,
      icon: Icon(
        Ionicons.caret_down_outline,
        color: Theme.of(context).textTheme.bodySmall!.color,
      ),
      hint: Text(
        tr("search.hint.type"),
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
      ),
      items: getDynamicMenu(widget.attr_id),
      onChanged: (value){
        print('onChanged');
        setState(() {
          selected = int.parse(value);
        });
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
