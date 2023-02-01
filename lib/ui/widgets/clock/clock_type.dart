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
  var selected = 0;
  // final GlobalKey<FormFieldState> _statusKey = GlobalKey<FormFieldState>();
  List<DropdownMenuItem> getDynamicMenu(attr_id) {
    List<DropdownMenuItem> dynamicMenus = [];
    if (widget.allType.isNotEmpty && widget.attr_id != null && attr_id != null) {
      widget.allType['$attr_id']['child'].forEach((k, v) {
        // print('type_init_value');
        // print(widget.type_init_value);
        // print('selected');
        // print(selected);

        // if (widget.type_init_value == true || selected != k) {
          dynamicMenus.add(DropdownMenuItem(key: ValueKey(k), value: '$k', child: Text(v['name'])),);
        // }
      });
    }
    return dynamicMenus;
  }

  @override
  Widget build(BuildContext context) {
    // var test =
    if (widget.type_init_value == false) {
      setState(() {
        selected = 0;
      });
    }
    print(selected);
    // print('type_init_value');
    // print(widget.type_init_value);
    return DropdownButtonFormField(
      dropdownColor: Theme.of(context).colorScheme.surface,
      key: widget.type_init_value == false ? ValueKey(0) : ValueKey('1') ,
      // key: ValueKey(selected),
      icon: Icon(
        Ionicons.caret_down_outline,
        color: Theme.of(context).textTheme.bodySmall!.color,
      ),
      hint: Text(
        tr("search.hint.status"),
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
      ),
      // value: selected == 0 ? null : selected,
      items: getDynamicMenu(widget.attr_id),
      onChanged: (value){
        print('onChanged');
        setState(() {
          selected = int.parse(value);
        });
        widget.callback(value);
      },
      onTap: (){
        print('Tapppp');
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
