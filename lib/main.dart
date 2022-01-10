import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test_task/model/colored_checkbox.dart';

import 'const.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: CustomBoxesPage(),
    );
  }
}

class CustomBoxesPage extends StatefulWidget {
  CustomBoxesPage({Key? key}) : super(key: key);

  @override
  _CustomBoxesPageState createState() => _CustomBoxesPageState();
}

class _CustomBoxesPageState extends State<CustomBoxesPage>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  late AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: 100,
    ),
  );
  late Animation radiusColored;
  double radius = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
    radiusColored = Tween(begin: 0.0, end: 16.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.1, 1.0),
      )..addListener(() {
          setState(() {
            radius = radiusColored.value;
          });
        }),
    );
  }

  final colorDefault = ValueNotifier<Color>(Colors.transparent);
  final currentAnimation = ValueNotifier(0.0);
  final list = <ColoredCheckbox>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom CheckBox'),
        backgroundColor: Colors.pinkAccent[100],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                padding: const EdgeInsets.all(0.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  // childAspectRatio: 1.5,
                  // crossAxisSpacing: 2.0,
                  // mainAxisSpacing: 4.0,
                ),
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  return ValueListenableBuilder(
                    valueListenable: colorDefault,
                    builder: (context, value, _) => GestureDetector(
                      onTap: () {
                        _controller.reset();
                        _controller.forward();
                        _controller.addStatusListener(
                          (status) {
                            if (status == AnimationStatus.completed) {
                              // _controller.reset();
                              // _controller.stop();
                            }
                          },
                        );
                        list[index].checkValue(list[index].colorValue);
                        colorDefault.value = list[index].color!;
                        list
                            .map(
                              (e) => e.selectedValue =
                                  (e.color == colorDefault.value)
                                      ? true
                                      : false,
                            )
                            .toList();
                      },
                      child: CustomPaint(
                        foregroundPainter: DrawLine(),
                        painter: FillCustomBox(
                          radius: radius,
                          selected: list[index].selectedValue,
                          activeColor: list[index].color ?? Colors.transparent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(animationDuration),
            Slider(
              onChanged: (newRating) {
                setState(() => currentAnimation.value = newRating);
                _controller.duration = Duration(
                    milliseconds: 100 + currentAnimation.value.toInt() * 10);
              },
              value: currentAnimation.value,
              min: 0,
              max: 100,
            ),
            Text('${currentAnimation.value.roundToDouble()} ms for animation'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (int i = 0; i < 10; i++) {
                        list.add(
                          ColoredCheckbox(
                            EnumColor.values[
                                Random().nextInt(EnumColor.values.length)],
                          ),
                        );
                      }
                      list
                          .map(
                            (e) => e.selectedValue =
                                (e.color == colorDefault.value) ? true : false,
                          )
                          .toList();
                    });
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  child: Text(addBtn),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      list.clear();
                    });
                  },
                  child: Text(clearBtn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FillCustomBox extends CustomPainter {
  final double radius;
  final Color activeColor;
  final bool selected;

  FillCustomBox({
    required this.radius,
    required this.selected,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final offsetCenter = Offset(
      size.width / 2,
      size.height / 2,
    );

    final fillBox = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0
      ..isAntiAlias = false;

    canvas.drawCircle(
      offsetCenter,
      offsetCenter.dx / 2,
      Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );

    if (selected == true) canvas.drawCircle(offsetCenter, radius, fillBox);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final offsetCenter = Offset(
      size.width / 2,
      size.height / 2,
    );

    final path = Path()
      ..moveTo(offsetCenter.dx - 1, offsetCenter.dy + 6)
      ..lineTo(offsetCenter.dx - 7, offsetCenter.dy - 2)
      ..moveTo(-offsetCenter.dx - 1, offsetCenter.dy + 6)
      ..lineTo(-offsetCenter.dx + 8, offsetCenter.dy - 5);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
