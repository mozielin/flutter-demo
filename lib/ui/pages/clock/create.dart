import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:ionicons/ionicons.dart';

import '../../widgets/common/main_appbar.dart';

enum SingingCharacter { lafayette, jefferson }

class CreateClock extends StatefulWidget {
  @override
  State<CreateClock> createState() => _CreateClockState();
}

class _CreateClockState extends State<CreateClock> {
  SingingCharacter? _character = SingingCharacter.lafayette;
  final ScrollController scrollController = ScrollController();
  final  _controller = TextEditingController();
  bool showbtn = false;

  @override
  void initState() {
    scrollController.addListener(() {
      double showOffset = 10.0;

      if (scrollController.offset > showOffset) {
        setState(() {
          showbtn = true;
        });
      } else {
        setState(() {
          showbtn = false;
        });
      }

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    final type = arguments['type'];
    String _input = tr("clock.create.depart_time_labelText");
    return Scaffold(
      appBar: MainAppBar(
        title: tr("clock.appbar.create"),
        appBar: AppBar(),
      ),
      body: Material(
        color: Theme.of(context).colorScheme.background,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      tr("clock.create.attr"),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(tr("clock.create.attr_project")),
                      leading: Radio<SingingCharacter>(
                        value: SingingCharacter.lafayette,
                        groupValue: _character,
                        onChanged: (SingingCharacter? value) {
                          setState(() {
                            _character = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(tr("clock.create.attr_office")),
                      leading: Radio<SingingCharacter>(
                        value: SingingCharacter.jefferson,
                        groupValue: _character,
                        onChanged: (SingingCharacter? value) {
                          setState(() {
                            _character = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(tr("clock.create.attr_day_off")),
                      leading: Radio<SingingCharacter>(
                        value: SingingCharacter.jefferson,
                        groupValue: _character,
                        onChanged: (SingingCharacter? value) {
                          setState(() {
                            _character = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      tr("clock.create.internal_order"),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ), //Internal order
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: TextFormField(
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 15),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: const OutlineInputBorder(),
                            labelText:
                                tr("clock.create.internal_order_labelText"),
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ), //Internal order input
                const Padding(padding: EdgeInsets.only(top: 5)),
                Row(
                  children: [
                    Text(
                      tr("clock.create.type"),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    DropdownButtonFormField(
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      // key: _statusKey,
                      icon: Icon(
                        Ionicons.caret_down_outline,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                      hint: Text(
                        tr("search.hint.status"),
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodySmall!.color),
                      ),
                      value: null,
                      items: [
                        DropdownMenuItem(value: '1', child: Text('1')),
                        DropdownMenuItem(value: '2', child: Text('2')),
                      ],
                      onChanged: (value) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        // setState(() {
                        //   _status = value!;
                        // });
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: const OutlineInputBorder(),
                      ),
                    )
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                Row(
                  children: [
                    Text(
                      tr("clock.create.child_type"),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    DropdownButtonFormField(
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      // key: _statusKey,
                      icon: Icon(
                        Ionicons.caret_down_outline,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                      hint: Text(
                        tr("search.hint.status"),
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodySmall!.color),
                      ),
                      value: null,
                      items: [
                        DropdownMenuItem(value: '1', child: Text('1')),
                        DropdownMenuItem(value: '2', child: Text('2')),
                      ],
                      onChanged: (value) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        // setState(() {
                        //   _status = value!;
                        // });
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: const OutlineInputBorder(),
                      ),
                    )
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                Row(
                  children: [
                    Text(
                      tr("clock.create.depart_time"),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 15),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: const OutlineInputBorder(),
                        labelText: _input,
                        labelStyle: TextStyle(
                          color:
                          Theme.of(context).textTheme.bodySmall!.color,
                        ),
                        suffixIcon: IconButton(onPressed: () {
                          DatePicker.showDateTimePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(2018, 3, 5),
                              maxTime: DateTime(2019, 6, 7), onChanged: (date) {

                                print('change $_controller');
                              }, onConfirm: (date) {
                                _controller.text = DateFormat('yyyy-MM-dd kk:mm').format(date);
                                // FocusScope.of(context).requestFocus(FocusNode());
                                print('confirm $date');
                              },
                              currentTime: DateTime.now(),
                              locale: LocaleType.zh);
                        },
                          icon: Icon(Ionicons.calendar_outline),
                          // child: Text(
                          //   'show date time picker (Chinese)',
                          //   style: TextStyle(color: Colors.blue),
                          // )
                        )
                      ),
                    ),
                    // InputDatePickerFormField(firstDate: DateTime.now(), lastDate: DateTime.now())

                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                Row(
                  children: [
                    Text(
                      tr("clock.create.start_time"),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: const OutlineInputBorder(),
                          labelText: _input,
                          labelStyle: TextStyle(
                            color:
                            Theme.of(context).textTheme.bodySmall!.color,
                          ),
                          suffixIcon: IconButton(onPressed: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(2018, 3, 5),
                                maxTime: DateTime(2019, 6, 7), onChanged: (date) {

                                  print('change $_controller');
                                }, onConfirm: (date) {
                                  _controller.text = DateFormat('yyyy-MM-dd kk:mm').format(date);
                                  // FocusScope.of(context).requestFocus(FocusNode());
                                  print('confirm $date');
                                },
                                currentTime: DateTime.now(),
                                locale: LocaleType.zh);
                          },
                            icon: Icon(Ionicons.calendar_outline),
                            // child: Text(
                            //   'show date time picker (Chinese)',
                            //   style: TextStyle(color: Colors.blue),
                            // )
                          )
                      ),
                    ),
                    // InputDatePickerFormField(firstDate: DateTime.now(), lastDate: DateTime.now())

                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                Row(
                  children: [
                    Text(
                      tr("clock.create.end_time"),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: const OutlineInputBorder(),
                          labelText: _input,
                          labelStyle: TextStyle(
                            color:
                            Theme.of(context).textTheme.bodySmall!.color,
                          ),
                          suffixIcon: IconButton(onPressed: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(2018, 3, 5),
                                maxTime: DateTime(2019, 6, 7), onChanged: (date) {

                                  print('change $_controller');
                                }, onConfirm: (date) {
                                  _controller.text = DateFormat('yyyy-MM-dd kk:mm').format(date);
                                  // FocusScope.of(context).requestFocus(FocusNode());
                                  print('confirm $date');
                                },
                                currentTime: DateTime.now(),
                                locale: LocaleType.zh);
                          },
                            icon: Icon(Ionicons.calendar_outline),
                            // child: Text(
                            //   'show date time picker (Chinese)',
                            //   style: TextStyle(color: Colors.blue),
                            // )
                          )
                      ),
                    ),
                    // InputDatePickerFormField(firstDate: DateTime.now(), lastDate: DateTime.now())

                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                Row(
                  children: [
                    Text(
                      tr("clock.create.internal_order"),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ), //Internal order
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: TextFormField(
                          decoration: InputDecoration(
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: const OutlineInputBorder(),
                            labelText:
                            tr("clock.create.internal_order_labelText"),
                            labelStyle: TextStyle(
                              color:
                              Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ), //
              ],
            ),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
