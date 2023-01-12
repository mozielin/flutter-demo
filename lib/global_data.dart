// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:flutter/material.dart';

class GlobalData extends InheritedModel<GlobalData> {
  String? photo_file_base64_title;
  String? photo_file_base64;

  GlobalData({super.key, required Widget child}) : super(child: child);

  static GlobalData? of(BuildContext context, {String? aspect}) =>
      InheritedModel.inheritFrom<GlobalData>(context, aspect: aspect);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(GlobalData oldWidget, Set dependencies) {
    if (dependencies.contains('photo_file_base64_title') &&
        oldWidget.photo_file_base64_title != photo_file_base64_title) {
      return true;
    }
    if (dependencies.contains('photo_file_base64') &&
        oldWidget.photo_file_base64 != photo_file_base64) {
      return true;
    }
    return false;
  }
}