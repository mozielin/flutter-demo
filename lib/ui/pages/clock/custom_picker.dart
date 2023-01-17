import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_datetime_picker/src/date_format.dart';
import 'package:flutter_datetime_picker/src/i18n_model.dart';


// void main() => runApp(new MyApp());

// class CustomPicker extends CommonPickerModel {
//   late DateTime maxTime;
//   late DateTime minTime;
//
//   String digits(int value, int length) {
//     return '$value'.padLeft(length, "0");
//   }
//
//   CustomPicker(
//       {DateTime? currentTime,
//        DateTime? maxTime,
//        DateTime? minTime,
//        LocaleType? locale})
//       : super(locale: locale) {
//     this.currentTime = currentTime ?? DateTime.now();
//     this.setLeftIndex(this.currentTime.hour);
//     this.setMiddleIndex(this.currentTime.minute);
//     this.setRightIndex(this.currentTime.second);
//     this.maxTime = maxTime ?? DateTime(2049, 12, 31);
//     this.minTime = minTime ?? DateTime(1970, 1, 1);
//   }
//   @override
//   void setLeftIndex(int index) {
//     super.setLeftIndex(index);
//     DateTime time = currentTime.add(Duration(days: index));
//     if (isAtSameDay(minTime, time)) {
//       var index = min(24 - minTime!.hour - 1, _currentMiddleIndex);
//       this.setMiddleIndex(index);
//     } else if (isAtSameDay(maxTime, time)) {
//       var index = min(maxTime!.hour, _currentMiddleIndex);
//       this.setMiddleIndex(index);
//     }
//   }
//
//   @override
//   String? leftStringAtIndex(int index) {
//     DateTime time = currentTime.add(Duration(days: index));
//     if (minTime != null &&
//         time.isBefore(minTime!) &&
//         !isAtSameDay(minTime!, time)) {
//       return null;
//     } else if (maxTime != null &&
//         time.isAfter(maxTime!) &&
//         !isAtSameDay(maxTime, time)) {
//       return null;
//     }
//     return formatDate(time, [ymdw], locale);
//   }
//
//   bool isAtSameDay(DateTime? day1, DateTime? day2) {
//     return day1 != null &&
//         day2 != null &&
//         day1.difference(day2).inDays == 0 &&
//         day1.day == day2.day;
//   }
//
//   @override
//   String? middleStringAtIndex(int index) {
//     if (index >= 0 && index < 60) {
//       return this.digits(index, 2);
//     } else {
//       return null;
//     }
//   }
//
//   @override
//   String? rightStringAtIndex(int index) {
//     print(index);
//     if (index >= 0 && index < 60) {
//       return this.digits(index, 2);
//     } else {
//       return null;
//     }
//   }
//
//   @override
//   String leftDivider() {
//     return "|";
//   }
//
//   @override
//   String rightDivider() {
//     return "|";
//   }
//
//   @override
//   List<int> layoutProportions() {
//     return [1, 2, 1];
//   }
//
//   @override
//   DateTime finalTime() {
//     return currentTime.isUtc
//         ? DateTime.utc(
//         currentTime.year,
//         currentTime.month,
//         currentTime.day,
//         this.currentLeftIndex(),
//         this.currentMiddleIndex(),
//         this.currentRightIndex())
//         : DateTime(
//         currentTime.year,
//         currentTime.month,
//         currentTime.day,
//         this.currentLeftIndex(),
//         this.currentMiddleIndex(),
//         this.currentRightIndex());
//   }
// }
class CustomPicker extends DateTimePickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }
  DateTime? maxTime;
  DateTime? minTime;

  CustomPicker(
      {DateTime? currentTime,
        DateTime? maxTime,
        DateTime? minTime,
        LocaleType? locale})
      : super(locale: locale) {
    if (currentTime != null) {
      this.currentTime = currentTime;
      if (maxTime != null &&
          (currentTime.isBefore(maxTime) ||
              currentTime.isAtSameMomentAs(maxTime))) {
        this.maxTime = maxTime;
      }
      if (minTime != null &&
          (currentTime.isAfter(minTime) ||
              currentTime.isAtSameMomentAs(minTime))) {
        this.minTime = minTime;
      }
    } else {
      this.maxTime = maxTime;
      this.minTime = minTime;
      var now = DateTime.now();
      if (this.minTime != null && this.minTime!.isAfter(now)) {
        this.currentTime = this.minTime!;
      } else if (this.maxTime != null && this.maxTime!.isBefore(now)) {
        this.currentTime = this.maxTime!;
      } else {
        this.currentTime = now;
      }
    }

    if (this.minTime != null &&
        this.maxTime != null &&
        this.maxTime!.isBefore(this.minTime!)) {
      // invalid
      this.minTime = null;
      this.maxTime = null;
    }
    this.setRightIndex(this.currentTime.second);

    @override
    String? rightStringAtIndex(int index) {
      if (index >= 0 && index < 60) {
        return this.digits(1, 2);
      } else {
        return null;
      }
    }
  }
  // CustomPicker(
  //     {DateTime? currentTime,
  //      DateTime? maxTime,
  //      DateTime? minTime,
  //      LocaleType? locale})
  //     : super(locale: locale) {
  //   this.currentTime = currentTime ?? DateTime.now();
  //   this.setLeftIndex(this.currentTime.hour);
  //   this.setMiddleIndex(this.currentTime.minute);
  //   this.setRightIndex(this.currentTime.second);
  //   this.maxTime = maxTime ?? DateTime(2049, 12, 31);
  //   this.minTime = minTime ?? DateTime(1970, 1, 1);
  // }
}
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//       title: 'Flutter Demo',
//       theme: new ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: new HomePage(),
//     );
//   }
// }
//
// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Datetime Picker'),
//       ),
//       body: Center(
//         child: Column(
//           children: <Widget>[
//             TextButton(
//                 onPressed: () {
//                   DatePicker.showDatePicker(context,
//                       showTitleActions: true,
//                       minTime: DateTime(2018, 3, 5),
//                       maxTime: DateTime(2019, 6, 7),
//                       theme: DatePickerTheme(
//                           headerColor: Colors.orange,
//                           backgroundColor: Colors.blue,
//                           itemStyle: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18),
//                           doneStyle:
//                           TextStyle(color: Colors.white, fontSize: 16)),
//                       onChanged: (date) {
//                         print('change $date in time zone ' +
//                             date.timeZoneOffset.inHours.toString());
//                       }, onConfirm: (date) {
//                         print('confirm $date');
//                       }, currentTime: DateTime.now(), locale: LocaleType.en);
//                 },
//                 child: Text(
//                   'show date picker(custom theme &date time range)',
//                   style: TextStyle(color: Colors.blue),
//                 )),
//             TextButton(
//                 onPressed: () {
//                   DatePicker.showTimePicker(context, showTitleActions: true,
//                       onChanged: (date) {
//                         print('change $date in time zone ' +
//                             date.timeZoneOffset.inHours.toString());
//                       }, onConfirm: (date) {
//                         print('confirm $date');
//                       }, currentTime: DateTime.now());
//                 },
//                 child: Text(
//                   'show time picker',
//                   style: TextStyle(color: Colors.blue),
//                 )),
//             TextButton(
//                 onPressed: () {
//                   DatePicker.showTime12hPicker(context, showTitleActions: true,
//                       onChanged: (date) {
//                         print('change $date in time zone ' +
//                             date.timeZoneOffset.inHours.toString());
//                       }, onConfirm: (date) {
//                         print('confirm $date');
//                       }, currentTime: DateTime.now());
//                 },
//                 child: Text(
//                   'show 12H time picker with AM/PM',
//                   style: TextStyle(color: Colors.blue),
//                 )),
//             TextButton(
//                 onPressed: () {
//                   DatePicker.showDateTimePicker(context,
//                       showTitleActions: true,
//                       minTime: DateTime(2020, 5, 5, 20, 50),
//                       maxTime: DateTime(2020, 6, 7, 05, 09), onChanged: (date) {
//                         print('change $date in time zone ' +
//                             date.timeZoneOffset.inHours.toString());
//                       }, onConfirm: (date) {
//                         print('confirm $date');
//                       }, locale: LocaleType.zh);
//                 },
//                 child: Text(
//                   'show date time picker (Chinese)',
//                   style: TextStyle(color: Colors.blue),
//                 )),
//             TextButton(
//                 onPressed: () {
//                   DatePicker.showDateTimePicker(context, showTitleActions: true,
//                       onChanged: (date) {
//                         print('change $date in time zone ' +
//                             date.timeZoneOffset.inHours.toString());
//                       }, onConfirm: (date) {
//                         print('confirm $date');
//                       }, currentTime: DateTime(2008, 12, 31, 23, 12, 34));
//                 },
//                 child: Text(
//                   'show date time picker (English-America)',
//                   style: TextStyle(color: Colors.blue),
//                 )),
//             TextButton(
//                 onPressed: () {
//                   DatePicker.showDateTimePicker(context, showTitleActions: true,
//                       onChanged: (date) {
//                         print('change $date in time zone ' +
//                             date.timeZoneOffset.inHours.toString());
//                       }, onConfirm: (date) {
//                         print('confirm $date');
//                       },
//                       currentTime: DateTime(2008, 12, 31, 23, 12, 34),
//                       locale: LocaleType.nl);
//                 },
//                 child: Text(
//                   'show date time picker (Dutch)',
//                   style: TextStyle(color: Colors.blue),
//                 )),
//             TextButton(
//                 onPressed: () {
//                   DatePicker.showDateTimePicker(context, showTitleActions: true,
//                       onChanged: (date) {
//                         print('change $date in time zone ' +
//                             date.timeZoneOffset.inHours.toString());
//                       }, onConfirm: (date) {
//                         print('confirm $date');
//                       },
//                       currentTime: DateTime(2008, 12, 31, 23, 12, 34),
//                       locale: LocaleType.ru);
//                 },
//                 child: Text(
//                   'show date time picker (Russian)',
//                   style: TextStyle(color: Colors.blue),
//                 )),
//             TextButton(
//                 onPressed: () {
//                   DatePicker.showDateTimePicker(context, showTitleActions: true,
//                       onChanged: (date) {
//                         print('change $date in time zone ' +
//                             date.timeZoneOffset.inHours.toString());
//                       }, onConfirm: (date) {
//                         print('confirm $date');
//                       },
//                       currentTime: DateTime.utc(2019, 12, 31, 23, 12, 34),
//                       locale: LocaleType.de);
//                 },
//                 child: Text(
//                   'show date time picker in UTC (German)',
//                   style: TextStyle(color: Colors.blue),
//                 )),
//             TextButton(
//                 onPressed: () {
//                   DatePicker.showPicker(context, showTitleActions: true,
//                       onChanged: (date) {
//                         print('change $date in time zone ' +
//                             date.timeZoneOffset.inHours.toString());
//                       }, onConfirm: (date) {
//                         print('confirm $date');
//                       },
//                       pickerModel: CustomPicker(currentTime: DateTime.now()),
//                       locale: LocaleType.en);
//                 },
//                 child: Text(
//                   'show custom time picker,\nyou can custom picker model like this',
//                   style: TextStyle(color: Colors.blue),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }