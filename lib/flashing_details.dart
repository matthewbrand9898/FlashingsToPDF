import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class FlashingDetails extends StatefulWidget {
  const FlashingDetails(
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
  State<FlashingDetails> createState() => _RenderFlashingState();
}

class _RenderFlashingState extends State<FlashingDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: Colors.deepPurple.shade500,
        title: const Text(
          "DETAILS",
          style: TextStyle(fontFamily: "Kanit", color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple.shade50),
            onPressed: () {
              /*
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FlashingDetails(
                            points: Provider.of<DesignerModel>(context,
                                    listen: false)
                                .points,
                            anglePos: Provider.of<DesignerModel>(context,
                                    listen: false)
                                .anglePositions,
                            lengthPos: Provider.of<DesignerModel>(context,
                                    listen: false)
                                .lengthPositions,
                            boundingBox: calculateBoundingBox(
                                Provider.of<DesignerModel>(context,
                                        listen: false)
                                    .points),
                          )),
                );
                */
            },
            child: const Text(
              "NEXT",
              style: TextStyle(fontFamily: "Kanit", color: Colors.white),
            ),
          ),
          const Padding(padding: EdgeInsets.only(right: 15)),
        ],
      ),
      body: Column(children: [
        const Padding(padding: EdgeInsets.all(50)),
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade200,
            ),
            width: MediaQuery.of(context).size.width - 50,
            child: Center(
              child: Container(
                color: Colors.grey.shade200,
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: FlashingDetailsCustomPainter(
                      points: widget.points, boundingBox: widget.boundingBox),
                ),
              ),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.all(10)),
        Row(
          children: [
            const Padding(padding: EdgeInsets.only(left: 25)),
            Text(
              'FLASHING DETAILS',
              style: TextStyle(
                  fontFamily: 'Kanit',
                  color: Colors.deepPurple.shade500,
                  fontSize: 20),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.only(top: 5)),
        Row(
          children: [
            const Padding(padding: EdgeInsets.only(left: 25)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        color: Colors.grey.shade700,
                      ),
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(top: 2),
                          border: UnderlineInputBorder(),
                          labelText: 'CUSTOMER',
                          labelStyle: TextStyle(fontFamily: 'kanit'),
                          hintText: 'Customer',
                          hintStyle: TextStyle(
                            fontFamily: 'Kanit',
                          )),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 25)),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        color: Colors.grey.shade700,
                      ),
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(top: 2),
                          border: UnderlineInputBorder(),
                          labelText: 'POSITION',
                          labelStyle: TextStyle(fontFamily: 'kanit'),
                          hintText: 'Position',
                          hintStyle: TextStyle(
                            fontFamily: 'Kanit',
                          )),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 25)),
          ],
        ),
      ]),
    );
  }
}

class FlashingDetailsCustomPainter extends CustomPainter {
  FlashingDetailsCustomPainter({
    required this.points,
    required this.boundingBox,
  });
  final Rect boundingBox;
  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    Paint linesPaint = Paint();
    linesPaint.color = Colors.grey.shade700;
    linesPaint.strokeWidth = 3;
    linesPaint.strokeCap = StrokeCap.round;

    Paint boxPaint = Paint();
    boxPaint.color = Colors.black;
    boxPaint.strokeWidth = 4;
    Paint pointsPaint = Paint();
    pointsPaint.color = Colors.deepPurple;
    pointsPaint.strokeWidth = 1.0;
    double containerScale = 100000 / 100;
    double scale = 100000 / boundingBox.longestSide;
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
                  (((100 - scaledBoundingBox.width) / 2)),
              (points[i].dy / containerScale * scale -
                      (scaledBoundingBox.top)) +
                  (((100 - scaledBoundingBox.height) / 2))),
          Offset(
              (points[i + 1].dx / containerScale * scale -
                      (scaledBoundingBox.left)) +
                  (((100 - scaledBoundingBox.width) / 2)),
              (points[i + 1].dy / containerScale * scale -
                      (scaledBoundingBox.top)) +
                  (((100 - scaledBoundingBox.height) / 2))),
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
  bool shouldRepaint(FlashingDetailsCustomPainter oldDelegate) => true;
}
