import 'dart:math';

import 'package:example/pages/example2_page.dart';
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

class Example1Page extends StatefulWidget {
  Example1Page({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _Example1PageState createState() => _Example1PageState();
}

class _Example1PageState extends State<Example1Page> with TickerProviderStateMixin {
  late final List<String> _shuffledAlphabet;
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Animation<double>> _animations = {};
  final Tween<double> _tween = Tween(begin: 0, end: 1.0);
  bool paused = false;

  @override
  void initState() {
    super.initState();

    _shuffledAlphabet = alphabet.split('').toList()..shuffle();
  }

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
      // key: _key,
      policy: OrderedTraversalPolicy(),
      actions: (state) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => state.prev(),
            tooltip: 'Previous',
            child: Icon(Icons.arrow_left),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => state.next(),
            tooltip: 'Next',
            child: Icon(Icons.arrow_right),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => state.focussedNode?.state?.shouldShowBackground =
                !(state.focussedNode?.state?.shouldShowBackground ?? false),
            tooltip: 'Toggle BG',
            child: Icon(Icons.image),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              paused ? state.resume() : state.pause();
              setState(() => paused = !paused);
            },
            tooltip: paused ? 'Resume' : 'Pause',
            child: Icon(paused ? Icons.play_arrow : Icons.pause),
          ),
        ],
      ),
      onStart: (_) => showIntroductionDialog(),
      onEnd: (_) => debugPrint('[WizardView] has ended'),
      background: background,
      child: Scaffold(
        appBar: AppBar(
          title: Text('WizardView Example1'),
          actions: [
            IconButton(
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Example2Page())),
              icon: Icon(Icons.refresh),
            )
          ],
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
                    // final constrastingColour = interpolateColour(1 - p);

                    if (_controllers[c] == null) {
                      final controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
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
                        WizardScope.of(context)?.animate();
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
                          debugLabel: c,
                          builder: (_, __) => GestureDetector(
                            onTap: () => WizardScope.of(context)?.next(),
                            child: Text(
                              c,
                              style: Theme.of(context).textTheme.headline4!.copyWith(color: colour),
                            ),
                          ),
                          overlays: [
                            WizardOverlay(
                              alignment: Alignment.bottomCenter,
                              child: Transform.scale(
                                scale: _animations[c]!.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).canvasColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: boxShadow),
                                  padding: padding,
                                  child: Text(
                                    'Other step ${c.toUpperCase()}',
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
      ),
    );
  }

  Future<void> showIntroductionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            TextButton(
              child: Text('Continue'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
          content: Column(
            children: [Text('WizardView'), Text('Welcome to this WizardView example!')],
          ),
        );
      },
    );
  }
}
