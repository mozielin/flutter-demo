import 'package:flutter/cupertino.dart';

class HoleClipper extends CustomClipper<Path> {
  final Offset offset;
  final double holeSize;

  HoleClipper({this.offset = const Offset(0, 0.285), this.holeSize = 20});

  @override
  Path getClip(Size size) {
    Path circlePath = Path();
    circlePath.addRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(5),
      ),
    );

    double w = size.width;
    double h = size.height;
    Offset offsetXY = Offset(offset.dx * w, offset.dy * h);
    double d = holeSize;
    _getHold(circlePath, 1, d, offsetXY, size);
    circlePath.fillType = PathFillType.evenOdd;
    return circlePath;
  }

  void _getHold(Path path, int count, double d, Offset offset, size) {
    // 左耳朵
    var left = offset.dx - 5;
    var top = 71; // offset.dy
    var right = left + d;
    var bottom = top + d;
    path.addOval(Rect.fromLTRB(left, 71, right, bottom));
    // 右耳朵
    var aLeft = offset.dx + size.width - 15;
    var aTop = 71; // offset.dy
    var aRight = aLeft + d;
    var aBottom = aTop + d;
    path.addOval(Rect.fromLTRB(aLeft, 71, aRight, aBottom));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}