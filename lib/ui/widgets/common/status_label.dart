// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

class StatusLabel extends StatelessWidget {
  const StatusLabel({
    super.key,
    required this.title,
    required this.color,
    required this.bg_color
  });

  final title;
  final color;
  final bg_color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: bg_color,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 2),
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
