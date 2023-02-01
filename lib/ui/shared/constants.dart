import 'package:flutter/material.dart';

const InputDecoration textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.all(12),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 2),
  ),
);