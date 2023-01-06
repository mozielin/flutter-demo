import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hws_app/main.dart';
import 'package:hws_app/ui/widgets/common/main_appbar.dart';
import 'package:photo_view/photo_view.dart';

class PhotoDetailBase64 extends StatelessWidget {
  const PhotoDetailBase64({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalData? g = GlobalData.of(context);

    return Scaffold(
      appBar: MainAppBar(
        title: '${g?.photo_file_base64_title}',
        appBar: AppBar(),
      ),
      body: PhotoView(
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
        maxScale: 2.0,
        minScale: 0.2,
        imageProvider: g?.photo_file_base64 != null
            ? Image.memory(base64Decode(g!.photo_file_base64!)).image
            : null,
      ),
    );
  }
}
