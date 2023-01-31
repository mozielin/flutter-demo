// ignore_for_file: non_constant_identifier_names

import 'package:easy_localization/easy_localization.dart';

String FormatThousandths(Number) {
  var format = NumberFormat('0,000');
  return format.format(Number);
}