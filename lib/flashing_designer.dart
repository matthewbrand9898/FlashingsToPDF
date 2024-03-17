import 'package:ars_flashings/angle_widget.dart';
import 'package:ars_flashings/cf1_widget.dart';
import 'package:ars_flashings/colour_direction_widget.dart';
import 'package:ars_flashings/edit_angle.dart';
import 'package:ars_flashings/edit_cf.dart';
import 'package:ars_flashings/edit_length.dart';

import 'package:ars_flashings/length_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'cf2_widget.dart';
import 'render_flashing_icon.dart';
import 'draw.dart';
import 'helper_functions.dart';
import 'models/designer_model.dart';

class FlashingDesigner extends StatelessWidget {
  FlashingDesigner({super.key});
  final GlobalKey<ConvexAppBarState> appBarKey = GlobalKey<ConvexAppBarState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        appBar: AppBar(
          backgroundColor: Colors.deepPurple.shade500,
          title: const Text(
            "DESIGNER",
            style: TextStyle(fontFamily: "OpenSans", color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.deepPurple.shade50),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RenderFlashing(
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
              },
              child: const Text(
                "Next",
                style: TextStyle(fontFamily: "OpenSans", color: Colors.white),
              ),
            )
          ],
        ),
        bottomNavigationBar: ConvexAppBar(
          key: appBarKey,
          backgroundColor: Colors.deepPurple.shade500,
          color: Colors.white,
          items: const [
            TabItem(
              icon: Icons.draw,
              title: 'DRAW',
              fontFamily: "OpenSans",
            ),
            TabItem(
              icon: Icons.edit_note,
              title: 'EDIT',
              fontFamily: "OpenSans",
            ),
            TabItem(
              icon: Icons.construction_rounded,
              title: 'CF',
              fontFamily: "OpenSans",
            ),
            TabItem(
              icon: Icons.rotate_left,
              title: 'ROTATE',
              fontFamily: "OpenSans",
            ),
            TabItem(
              icon: Icons.undo,
              title: 'UNDO',
              fontFamily: "OpenSans",
            ),
          ],
          onTap: (int i) {
            if (i < 4) {
              Provider.of<DesignerModel>(context, listen: false)
                  .editBottomBarIndex(i);
              i == 2
                  ? Provider.of<DesignerModel>(context, listen: false)
                      .editShowCrushAndFoldUI(true)
                  : Provider.of<DesignerModel>(context, listen: false)
                      .editShowCrushAndFoldUI(false);
            }
          },
          onTabNotify: (int i) {
            if (i == 1 || i == 2 || i == 3) {
              if (Provider.of<DesignerModel>(context, listen: false)
                      .points
                      .length <
                  2) return false;
            }

            var intercept = i == 4;
            if (intercept) {
              Provider.of<DesignerModel>(context, listen: false).Undo();
              if (Provider.of<DesignerModel>(context, listen: false)
                      .points
                      .length <
                  2) {
                appBarKey.currentState?.tap(0);
              }
            }
            return !intercept;
          },
        ),
        body: Stack(children: [
          Consumer<DesignerModel>(
            builder: (context, designerModel, child) {
              return InteractiveViewer(
                onInteractionUpdate: (scaleUpdateDetails) {
                  designerModel.editInteractiveZoomFactor(designerModel
                      .transformationController.value
                      .getMaxScaleOnAxis());

                  if (designerModel.oldInteractiveZoomFactor !=
                      designerModel.interactiveZoomFactor) {
                    for (int i = 0;
                        i < designerModel.lengthPositions.length;
                        i++) {
                      designerModel.editLengthPositionOffset(
                          i,
                          lengthOffset(
                              designerModel.points,
                              designerModel.lengthPositions,
                              designerModel.interactiveZoomFactor,
                              i + 1,
                              i,
                              verticalScaler(designerModel.points,
                                  designerModel.lengthPositions, i + 1, i)));
                    }

                    for (int i = 0;
                        i < designerModel.anglePositions.length;
                        i++) {
                      designerModel.editAnglePositionOffset(
                          i,
                          angleOffset(
                              designerModel.points,
                              designerModel.anglePositions,
                              designerModel.interactiveZoomFactor,
                              i + 1,
                              i));
                    }
                  }

                  designerModel.editOldInteractiveZoomFactor(
                      designerModel.interactiveZoomFactor);
                },
                transformationController:
                    designerModel.transformationController,
                maxScale: 5,
                minScale: 0.05,
                constrained: false,
                child: SizedBox(
                  width: 100000,
                  height: 100000,
                  child: Stack(
                    children: [
                      CustomPaint(
                        foregroundPainter: Draw(
                          points: designerModel.points,
                          lengthPositions: designerModel.lengthPositions,
                          lengthPositions_Offsets:
                              designerModel.lengthPositions_Offsets,
                          anglePositions_Offsets:
                              designerModel.anglePositions_Offsets,
                          anglePositions: designerModel.anglePositions,
                          bottomNavbarIndex: designerModel.bottomBarIndex,
                          scaleFactor: designerModel.interactiveZoomFactor,
                          boundingBox:
                              calculateBoundingBox(designerModel.points),
                          showCFUI: designerModel.showCrushAndFoldUI,
                          cF1_state: designerModel.cf_1State,
                          cF2_state: designerModel.cf_2State,
                          cF1_position: designerModel.cf_1Position,
                          cF1_length: designerModel.cf_1Length,
                          cF2_length: designerModel.cf_2Length,
                          cF2_position: designerModel.cf_2Position,
                          Hide_90_45Angles: designerModel.Hide90_45Angles,
                        ),
                        child: GridPaper(
                          color: Colors.grey,
                          divisions: 1,
                          interval: 200,
                          child: GestureDetector(
                            onTapUp: (TapUpDetails details) {
                              if (designerModel.bottomBarIndex == 1) {
                                for (int i = 1;
                                    i < designerModel.points.length - 1;
                                    i++) {
                                  Rect rect = Rect.fromCenter(
                                      center: designerModel.points[i],
                                      width: 40,
                                      height: 40);
                                  if (rect.contains(details.localPosition)) {
                                    designerModel.editShowAngleEdit(true);
                                    designerModel.editSelectedPointIndex(i);
                                  }
                                }
                              }

                              if (designerModel.bottomBarIndex == 3) {
                                for (int i = 0;
                                    i < designerModel.points.length;
                                    i++) {
                                  Rect rect = Rect.fromCenter(
                                      center: designerModel.points[i],
                                      width: 40,
                                      height: 40);
                                  if (rect.contains(details.localPosition)) {
                                    designerModel
                                        .editSelectedRotationPointIndex(i);
                                  }
                                }
                              }

                              if (designerModel.bottomBarIndex == 2) {
                                Offset cFdir_1 =
                                    calculateNormalizedDirectionVector(
                                        designerModel.points[1],
                                        designerModel.points[0]);
                                cFdir_1 *= 25 +
                                    (30 / designerModel.interactiveZoomFactor);
                                Offset cFdir_2 =
                                    calculateNormalizedDirectionVector(
                                        designerModel.points[
                                            designerModel.points.length - 2],
                                        designerModel.points[
                                            designerModel.points.length - 1]);
                                cFdir_2 *= 25 +
                                    (30 / designerModel.interactiveZoomFactor);
                                Rect CF1Rect = Rect.fromCenter(
                                    center: designerModel.points[0] + cFdir_1,
                                    width: 50 +
                                        (30 /
                                            designerModel
                                                .interactiveZoomFactor),
                                    height: 50 +
                                        (30 /
                                            designerModel
                                                .interactiveZoomFactor));
                                Rect CF2Rect = Rect.fromCenter(
                                    center: designerModel.points[
                                            designerModel.points.length - 1] +
                                        cFdir_2,
                                    width: 50 +
                                        (30 /
                                            designerModel
                                                .interactiveZoomFactor),
                                    height: 50 +
                                        (30 /
                                            designerModel
                                                .interactiveZoomFactor));

                                if (CF1Rect.contains(details.localPosition)) {
                                  if (designerModel.cf_1State == 0) {
                                    designerModel.editCf_1length(15);
                                  }
                                  designerModel.editCf_1State(
                                      designerModel.cf_1State + 1);

                                  if (designerModel.cf_1State > 2) {
                                    designerModel.editCf_1State(0);
                                    designerModel.editCf_1length(0);
                                  } else {
                                    designerModel.editCf_1Position(cf1Midpoint(
                                            designerModel.points,
                                            designerModel.cf_1State,
                                            designerModel.cf_1Length,
                                            designerModel
                                                .interactiveZoomFactor) -
                                        (calculatePerpendicularVector(
                                                designerModel.points[0],
                                                designerModel.points[1]) *
                                            (designerModel.cf_1State == 1
                                                ? -1
                                                : 1)));
                                  }
                                }
                                if (CF2Rect.contains(details.localPosition)) {
                                  if (designerModel.cf_2State == 0) {
                                    designerModel.editCf_2length(15);
                                  }
                                  designerModel.editCf_2State(
                                      designerModel.cf_2State + 1);

                                  if (designerModel.cf_2State > 2) {
                                    designerModel.editCf_2State(0);
                                    designerModel.editCf_2length(0);
                                  } else {
                                    designerModel.editCf_2Position(cf2Midpoint(
                                            designerModel.points,
                                            designerModel.cf_2State,
                                            designerModel.cf_2Length,
                                            designerModel
                                                .interactiveZoomFactor) -
                                        (calculatePerpendicularVector(
                                                designerModel.points[
                                                    designerModel
                                                            .points.length -
                                                        2],
                                                designerModel.points[
                                                    designerModel
                                                            .points.length -
                                                        1]) *
                                            (designerModel.cf_2State == 1
                                                ? -1
                                                : 1)));
                                  }
                                }
                              }

                              if (!designerModel.points.contains(Offset(
                                      (details.localPosition.dx / 40)
                                              .roundToDouble() *
                                          40,
                                      (details.localPosition.dy / 40)
                                              .roundToDouble() *
                                          40)) &&
                                  designerModel.bottomBarIndex == 0) {
                                designerModel.addPoint(Offset(
                                    (details.localPosition.dx / 40)
                                            .roundToDouble() *
                                        40,
                                    (details.localPosition.dy / 40)
                                            .roundToDouble() *
                                        40));
                                if (designerModel.points.length > 1) {
                                  designerModel.addLengthPosition(
                                      initialLengthPos(
                                          designerModel.points,
                                          designerModel.points.length - 1,
                                          designerModel.points.length - 2));
                                  designerModel.addLengthScale(1);

                                  designerModel.addLengthPositionOffset(
                                      lengthOffset(
                                          designerModel.points,
                                          designerModel.lengthPositions,
                                          designerModel.interactiveZoomFactor,
                                          designerModel.points.length - 1,
                                          designerModel.points.length - 2,
                                          verticalScaler(
                                              designerModel.points,
                                              designerModel.lengthPositions,
                                              designerModel.points.length - 1,
                                              designerModel.points.length -
                                                  2)));

                                  designerModel.updateColourPosition();
                                  if (designerModel.cf_2State != 0) {
                                    designerModel.editCf_2Position(cf2Midpoint(
                                            designerModel.points,
                                            designerModel.cf_2State,
                                            designerModel.cf_2Length,
                                            designerModel
                                                .interactiveZoomFactor) -
                                        (calculatePerpendicularVector(
                                                designerModel.points[
                                                    designerModel
                                                            .points.length -
                                                        2],
                                                designerModel.points[
                                                    designerModel
                                                            .points.length -
                                                        1]) *
                                            (designerModel.cf_2State == 1
                                                ? -1
                                                : 1)));
                                  }
                                }
                                if (designerModel.points.length > 2) {
                                  designerModel.addAnglePosition(
                                      initialAnglePos(
                                          designerModel.points,
                                          designerModel.points.length - 1,
                                          designerModel.points.length - 2));
                                  designerModel.addAngleScale(1);

                                  designerModel.addAnglePositionOffset(
                                      angleOffset(
                                          designerModel.points,
                                          designerModel.anglePositions,
                                          designerModel.interactiveZoomFactor,
                                          designerModel.points.length - 2,
                                          designerModel.anglePositions.length -
                                              1));
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      if (designerModel.points.isNotEmpty &&
                          designerModel.bottomBarIndex == 1)
                        for (var i = 1; i < designerModel.points.length; i++)
                          LengthWidget(index: i),
                      if (designerModel.points.length > 2 &&
                          designerModel.bottomBarIndex == 1)
                        for (var i = 1;
                            i < designerModel.points.length - 1;
                            i++)
                          if (calculateAngle(
                                              designerModel.points[i - 1],
                                              designerModel.points[i],
                                              designerModel.points[i + 1])
                                          .round() !=
                                      90 &&
                                  calculateAngle(
                                              designerModel.points[i - 1],
                                              designerModel.points[i],
                                              designerModel.points[i + 1])
                                          .round() !=
                                      45 &&
                                  calculateAngle(
                                              designerModel.points[i - 1],
                                              designerModel.points[i],
                                              designerModel.points[i + 1])
                                          .round() !=
                                      135 ||
                              designerModel.Hide90_45Angles == false)
                            AngleWidget(index: i),
                      if (designerModel.cf_1State != 0 &&
                          designerModel.bottomBarIndex == 1)
                        const CF1Widget(),
                      if (designerModel.cf_2State != 0 &&
                          designerModel.bottomBarIndex == 1)
                        const CF2Widget(),
                      if (designerModel.points.isNotEmpty &&
                          designerModel.bottomBarIndex == 3 &&
                          designerModel.points.length >=
                              designerModel.SelectedRotationPoint + 1)
                        Positioned(
                          left: designerModel
                                  .points[designerModel.SelectedRotationPoint]
                                  .dx -
                              75,
                          top: designerModel
                                  .points[designerModel.SelectedRotationPoint]
                                  .dy -
                              75,
                          child: Transform.scale(
                            scale: 1 / designerModel.interactiveZoomFactor,
                            child: SleekCircularSlider(
                              appearance: CircularSliderAppearance(
                                  customWidths: CustomSliderWidths(
                                    trackWidth: 7,
                                  ),
                                  angleRange: 360,
                                  startAngle: 0,
                                  customColors: CustomSliderColors(
                                      trackColor: Colors.deepPurple.shade500,
                                      progressBarColor:
                                          Colors.deepPurple.shade500,
                                      hideShadow: true)),
                              initialValue: 0,
                              min: 0,
                              max: 360,
                              onChange: (double value) {
                                designerModel.editFlashingRotationAngle(
                                    (value / 5).round() * 5.0);
                                // callback providing a value while its being changed (with a pan gesture)
                              },
                              onChangeStart: (double startValue) {
                                // callback providing a starting value (when a pan gesture starts)
                              },
                              onChangeEnd: (double endValue) {
                                // ucallback providing an ending value (when a pan gesture ends)
                              },
                              innerWidget: (double value) {
                                return Center(
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.deepPurple.shade500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      if (designerModel.bottomBarIndex == 1 &&
                          designerModel.points.length >= 2)
                        const ColourDirection(),
                    ],
                  ),
                ),
              );
            },
          ),
          if (Provider.of<DesignerModel>(context, listen: true).showLengthEdit)
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom == 0
                  ? MediaQuery.of(context).viewInsets.bottom
                  : MediaQuery.of(context).viewInsets.bottom - 50,
              child: SizedBox(
                width: constraints.maxWidth,
                child: const EditLength(),
              ),
            ),
          if (Provider.of<DesignerModel>(context, listen: true).showCFEdit)
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom == 0
                  ? MediaQuery.of(context).viewInsets.bottom
                  : MediaQuery.of(context).viewInsets.bottom - 50,
              child: SizedBox(
                width: constraints.maxWidth,
                child: const EditCFLength(),
              ),
            ),
          if (Provider.of<DesignerModel>(context, listen: true).showAngleEdit)
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom == 0
                  ? MediaQuery.of(context).viewInsets.bottom
                  : MediaQuery.of(context).viewInsets.bottom - 50,
              child: SizedBox(
                width: constraints.maxWidth,
                child: const EditAngle(),
              ),
            ),
          if (Provider.of<DesignerModel>(context, listen: true)
                  .bottomBarIndex ==
              1)
            Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.only(topLeft: Radius.circular(15)),
                    color: Colors.deepPurple.shade500,
                  ),
                  child: Center(
                    child: AutoSizeText(
                      "GIRTH ${Provider.of<DesignerModel>(context, listen: true).girth}",
                      style: const TextStyle(
                          fontFamily: "OpenSans", color: Colors.white),
                    ),
                  ),
                )),
          if (Provider.of<DesignerModel>(context, listen: true)
                  .bottomBarIndex ==
              1)
            Positioned(
                left: 10,
                top: 10,
                child: IconButton(
                  color: Colors.deepPurple.shade500,
                  icon: Icon(Provider.of<DesignerModel>(context, listen: false)
                          .Hide90_45Angles
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    Provider.of<DesignerModel>(context, listen: false)
                        .editHide90_45Angles(
                            !Provider.of<DesignerModel>(context, listen: false)
                                .Hide90_45Angles);
                  },
                )),
          if (Provider.of<DesignerModel>(context, listen: true)
                  .bottomBarIndex ==
              1)
            Positioned(
                left: 10,
                top: 50,
                child: IconButton(
                  color: Colors.deepPurple.shade500,
                  icon: Icon(Icons.swap_horiz_rounded),
                  onPressed: () {
                    Provider.of<DesignerModel>(context, listen: false)
                        .swapColourSide();
                  },
                )),
          if (Provider.of<DesignerModel>(context, listen: true)
                  .bottomBarIndex ==
              1)
            Positioned(
                bottom: 100,
                left: 50,
                child: IconButton(
                  color: Colors.deepPurple.shade500,
                  icon: Icon(Icons.rectangle),
                  onPressed: () {
                    if (Provider.of<DesignerModel>(context, listen: false)
                            .tapered ==
                        false) {
                      Provider.of<DesignerModel>(context, listen: false)
                          .enableTaper();
                    } else {
                      Provider.of<DesignerModel>(context, listen: false)
                          .disableTaper();
                    }
                  },
                )),
          if (Provider.of<DesignerModel>(context, listen: true)
                      .bottomBarIndex ==
                  1 &&
              Provider.of<DesignerModel>(context, listen: true).tapered)
            Positioned(
                bottom: 102,
                left: 200,
                child: TextButton(
                  child: Text(
                    'FAR',
                    style: TextStyle(
                        color: Colors.deepPurple.shade500,
                        fontFamily: 'OpenSans'),
                  ),
                  onPressed: () {
                    if (Provider.of<DesignerModel>(context, listen: false)
                            .taperedState !=
                        1) {
                      Provider.of<DesignerModel>(context, listen: false)
                          .swapTaper(1);
                    }
                  },
                )),
          if (Provider.of<DesignerModel>(context, listen: true)
                      .bottomBarIndex ==
                  1 &&
              Provider.of<DesignerModel>(context, listen: true).tapered)
            Positioned(
                bottom: 102,
                left: 100,
                child: TextButton(
                  child: Text(
                    'NEAR',
                    style: TextStyle(
                        color: Colors.deepPurple.shade500,
                        fontFamily: 'OpenSans'),
                  ),
                  onPressed: () {
                    if (Provider.of<DesignerModel>(context, listen: false)
                            .taperedState !=
                        0) {
                      Provider.of<DesignerModel>(context, listen: false)
                          .swapTaper(0);
                    }
                  },
                )),
        ]),
      );
    });
  }
}
