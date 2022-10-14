import 'package:flutter/material.dart';

class CircleTabIndicator extends Decoration {
  //the CircleTabIndicator is used with the Tabs and ProfilePostView widgets.
  //This small dot is diplayed under the title. To be done, it requires a class to extend Decoration

  //As for now,, bboth implementation of this Class use electriBlueColor
  final Color color;
  final double radius;
  const CircleTabIndicator({required this.color, required this.radius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    //createBoxPainter returns a BoxPainter obbject.
    //BoxPainter, however is an abstract class, so we have to override its methods.
    return _CirclePainter(color: color, radius: radius);
  }
}

class _CirclePainter extends BoxPainter {
  final Color color;
  final double radius;

  _CirclePainter({required this.color, required this.radius});
  //the method to override is paint, which is where the actual dot is drawn

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final _paint = Paint();
    _paint.color = color;
    _paint.isAntiAlias = true;
    final circleOffset = Offset(configuration.size!.width / 2 - radius / 2 + 2,
        configuration.size!.height - radius);
    //In particular, the method drawCircle is used. It takes as parameters the offset, the circleOffset which is defined using the radius, and the radius itself.
    canvas.drawCircle(offset + circleOffset, radius, _paint);
  }
}
