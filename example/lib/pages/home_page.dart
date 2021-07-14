import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wizardview/wizardview.dart';

const alphabet = 'abcdefghijklmnopqrstuvwxyz';

Color interpolateColour(double n) {
  if (n < 1 / 6) {
    final p = n * 6;
    return Color.fromRGBO(255, (255 * p).toInt(), 0, 1.0);
  } else if (n < 2 / 6) {
    final p = (n - 1 / 6) * 6;
    return Color.fromRGBO((255 * (1 - p)).toInt(), 255, 0, 1.0);
  } else if (n < 3 / 6) {
    final p = (n - 2 / 6) * 6;
    return Color.fromRGBO(0, 255, (255 * p).toInt(), 1.0);
  } else if (n < 4 / 6) {
    final p = (n - 3 / 6) * 6;
    return Color.fromRGBO(0, (255 * (1 - p)).toInt(), 255, 1.0);
  } else if (n < 5 / 6) {
    final p = (n - 4 / 6) * 6;
    return Color.fromRGBO((255 * p).toInt(), 0, 255, 1.0);
  } else {
    final p = (n - 5 / 6) * 6;
    return Color.fromRGBO(255, 0, (255 * (1 - p)).toInt(), 1.0);
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final List<String> _shuffledAlphabet;
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Animation<double>> _animations = {};
  final Tween<double> _tween = Tween(begin: 0, end: 1.0);

  @override
  void initState() {
    super.initState();

    _shuffledAlphabet = alphabet.characters.toList()..shuffle();
  }

  void _next(BuildContext context) => WizardScope.of(context).next();

  void _prev(BuildContext context) => WizardScope.of(context).prev();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final boxShadow = [
      BoxShadow(
        offset: Offset(0, 5),
        blurRadius: 5,
        color: Colors.black12,
      )
    ];
    const padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    final textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );
    final background = Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.black87,
    );

    return WizardScope(
      policy: OrderedTraversalPolicy(),
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(onPressed: () {}, child: Text('Skip Tutorial'))
        ],
      ),
      onStart: () => debugPrint('[WizardView] has started'),
      onEnd: () => debugPrint('[WizardView] has ended'),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return Stack(
              children: <Widget>[
                ...List.generate(
                  26,
                  (i) {
                    final c = _shuffledAlphabet[i];
                    final double p = i / 26,
                        r = min(size.width, size.height) / 4,
                        theta = 2 * pi * p,
                        x = cos(theta),
                        y = sin(theta);
                    final colour = interpolateColour(p);
                    final constrastingColour = interpolateColour(1 - p);

                    if (_controllers[c] == null) {
                      final controller = AnimationController(
                          vsync: this, duration: Duration(milliseconds: 300));
                      final animation = _tween.animate(
                        CurvedAnimation(
                          parent: controller,
                          curve: Curves.easeInOutCubic,
                        ),
                      );

                      controller.addListener(() {
                        // setState rebuilds this widget but not the `OverlayEntry` inside `WizardScope`
                        setState(() {});
                        // This actually rebuilds the `OverlayEntry`
                        WizardScope.of(context).animate();
                      });

                      _controllers.putIfAbsent(c, () => controller);
                      _animations.putIfAbsent(c, () => animation);
                    }
                    return Positioned(
                      top: y * r + size.height / 2,
                      left: x * r + size.width / 2,
                      child: FocusTraversalOrder(
                        order: LexicalFocusOrder(c),
                        child: Wizard(
                          child: GestureDetector(
                            onTap: () => WizardScope.of(context).next(),
                            child: Text(
                              c,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(color: colour),
                            ),
                          ),
                          background: background,
                          overlays: [
                            WizardOverlay.builder(
                              builder: (Offset offset, Size size) {
                                return Transform.scale(
                                  scale: _animations[c]!.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).canvasColor,
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                        boxShadow: boxShadow),
                                    padding: padding,
                                    child: Text(
                                      'Other step ${c.toUpperCase()}',
                                      style: textStyle,
                                    ),
                                  ),
                                );
                              },
                            ),
                            WizardOverlay(
                              child: Transform.scale(
                                scale: _animations[c]!.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).canvasColor,
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                      boxShadow: boxShadow),
                                  padding: padding,
                                  child: Text(
                                    'Other step ${c.toUpperCase()}',
                                    style: textStyle,
                                  ),
                                ),
                              ),
                            ),
                            WizardOverlay(
                              alignment: Alignment.topCenter,
                              child: Transform.scale(
                                scale: _animations[c]!.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).canvasColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                      boxShadow: boxShadow),
                                  padding: padding,
                                  child: Text(
                                    'Step ${c.toUpperCase()}',
                                    style: textStyle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          onNodeStart: () => _controllers[c]!.forward(),
                          onNodeEnd: () => _controllers[c]!.reverse(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () => _prev(context),
                tooltip: 'Previous',
                child: Icon(Icons.arrow_left),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                onPressed: () => _next(context),
                tooltip: 'Next',
                child: Icon(Icons.arrow_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
