import 'package:myuwi/Values/AppValues.dart';
import 'package:flutter/material.dart';

class DrawDesignLines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    //Top Line
    final l1p1 = Offset(-85, 25);
    final l1p2 = Offset(85, 25);
    final line1paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;
    canvas.drawLine(l1p1, l1p2, line1paint);

    //After logo Line
    final l2p1 = Offset(-85, 110);
    final l2p2 = Offset(85, 110);
    final line2paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;
    canvas.drawLine(l2p1, l2p2, line2paint);

    //Corner First Line
    final cl1p1 = Offset(-680, 110);
    final cl1p2 = Offset(-580, -20);
    final cline1paint = Paint()
      ..color = AppColors.ucDavisGoldLine
      ..strokeWidth = 60;
    canvas.drawLine(cl1p1, cl1p2, cline1paint);

    //Corner Second Line
    final c21p1 = Offset(-700, 270);
    final c21p2 = Offset(-480, -20);
    final c2ine1paint = Paint()
      ..color = AppColors.ucDavisGoldLine
      ..strokeWidth = 60;
    canvas.drawLine(c21p1, c21p2, c2ine1paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
