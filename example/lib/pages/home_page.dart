import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wizardview/wizardview.dart';

const alphabet = 'abcdefghijklmnopqrstuvwxyz';

//? I got bored okay
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

class _HomePageState extends State<HomePage> {
  late final List<String> shuffledAlphabet;

  @override
  void initState() {
    shuffledAlphabet = alphabet.characters.toList()..shuffle();
    super.initState();
  }

  void _incrementCounter(BuildContext context) {
    WizardScope.of(context).next();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WizardScope(
      policy: OrderedTraversalPolicy(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: <Widget>[
            ...List.generate(
              26,
              (i) {
                final c = shuffledAlphabet[i];
                final double p = i / 26,
                    r = size.width / 5 - size.width / 3 * sin(2 * pi * p),
                    theta = 2 * pi * p,
                    x = cos(theta),
                    y = sin(theta);
                final colour = interpolateColour(p);
                final constrastingColour = interpolateColour(1 - p);
                return Positioned(
                  top: y * r + size.height / 2,
                  left: x * r + size.width / 2,
                  child: FocusTraversalOrder(
                    order: LexicalFocusOrder(c),
                    child: Wizard(
                      child: Text(
                        c,
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: colour),
                      ),
                      background: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: constrastingColour.withOpacity(0.1),
                      ),
                      overlay: Container(
                        color: constrastingColour.withOpacity(0.5),
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => _incrementCounter(context),
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
