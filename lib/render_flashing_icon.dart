import 'package:flutter/material.dart';

class RenderFlashing extends StatefulWidget {
  const RenderFlashing(
      {required this.points,
      required this.anglePos,
      required this.lengthPos,
      required this.boundingBox,
      super.key});
  final List<Offset> points;
  final List<Offset> anglePos;
  final List<Offset> lengthPos;
  final Rect boundingBox;
  @override
  State<RenderFlashing> createState() => _RenderFlashingState();
}

class _RenderFlashingState extends State<RenderFlashing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Container(
            color: Colors.grey.shade50,
            width: 300,
            height: 300,
            child: CustomPaint(
              painter: RenderFlashingCustomPainter(
                  points: widget.points, boundingBox: widget.boundingBox),
            ),
          ),
        ));
  }
}

class RenderFlashingCustomPainter extends CustomPainter {
  RenderFlashingCustomPainter({
    required this.points,
    required this.boundingBox,
  });
  final Rect boundingBox;
  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    Paint linesPaint = Paint();
    linesPaint.color = Colors.grey.shade600;
    linesPaint.strokeWidth = 4;
    linesPaint.strokeCap = StrokeCap.round;
    Paint boxPaint = Paint();
    boxPaint.color = Colors.black;
    boxPaint.strokeWidth = 4;
    Paint pointsPaint = Paint();
    pointsPaint.color = Colors.deepPurple;
    pointsPaint.strokeWidth = 1.0;
    double containerScale = 10000 / 300;
    double scale = 10000 / boundingBox.longestSide;
    Rect scaledBoundingBox = Rect.fromLTRB(
        boundingBox.left / containerScale * scale,
        boundingBox.top / containerScale * scale,
        boundingBox.right / containerScale * scale,
        boundingBox.bottom / containerScale * scale);
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(
          Offset(
              (points[i].dx / containerScale * scale -
                      (scaledBoundingBox.left)) +
                  (((300 - scaledBoundingBox.width) / 2)),
              (points[i].dy / containerScale * scale -
                      (scaledBoundingBox.top)) +
                  (((300 - scaledBoundingBox.height) / 2))),
          Offset(
              (points[i + 1].dx / containerScale * scale -
                      (scaledBoundingBox.left)) +
                  (((300 - scaledBoundingBox.width) / 2)),
              (points[i + 1].dy / containerScale * scale -
                      (scaledBoundingBox.top)) +
                  (((300 - scaledBoundingBox.height) / 2))),
          linesPaint);
    }
    //for (int i = 0; i < points.length; i++) {
    //canvas.drawCircle(
    //Offset(
    //     points[i].dx / ContainerScale * scale - (scaledBoundingBox.left),
    //     points[i].dy / ContainerScale * scale - (scaledBoundingBox.top)),
    // 3,
    // pointsPaint);
    //}
  }

  @override
  bool shouldRepaint(RenderFlashingCustomPainter oldDelegate) => true;
}
