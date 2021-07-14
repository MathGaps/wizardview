import 'package:flutter/material.dart';
import 'package:wizardview/wizardview.dart';

class Example2Body extends StatefulWidget {
  const Example2Body({Key? key}) : super(key: key);

  @override
  _Example2BodyState createState() => _Example2BodyState();
}

class _Example2BodyState extends State<Example2Body> {
  final _fnController = TextEditingController();
  final _mnController = TextEditingController();
  final _lnController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final background = Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.black87,
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sign Up',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
          ),
          const SizedBox(
            height: 30,
          ),
          Card(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wizard(
                    overlays: [
                      WizardOverlay(
                        child: _InfoCard(label: 'Enter your first name here'),
                      ),
                      WizardOverlay(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.amber,
                        ),
                      ),
                      WizardOverlay(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.keyboard_arrow_left,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                    background: background,
                    child: SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _fnController,
                        decoration: InputDecoration(hintText: 'First Name'),
                        onSubmitted: (_) {
                          // key.currentState?.next();
                          WizardScope.of(context).next();
                        },
                      ),
                    ),
                    activeChild: SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _fnController,
                        decoration: InputDecoration(
                          hintText: 'First Name',
                          filled: true,
                          fillColor: Theme.of(context).canvasColor,
                        ),
                        onSubmitted: (_) {
                          // key.currentState?.next();
                          WizardScope.of(context).next();
                        },
                      ),
                    ),
                  ),
                  Wizard(
                    overlays: [
                      WizardOverlay(
                        child: _InfoCard(label: 'Enter your middle name here'),
                      ),
                      WizardOverlay(
                        alignment: Alignment(0.3, -1),
                        child: SizedBox(
                          height: 100,
                          child: Image.network(
                            'https://www.pngkit.com/png/full/440-4403397_magikarp-peeker-sticker-sticker.png',
                          ),
                        ),
                      ),
                    ],
                    background: background,
                    child: SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _mnController,
                        decoration: InputDecoration(hintText: 'Middle Name'),
                        onSubmitted: (_) {
                          // key.currentState?.next();
                          WizardScope.of(context).next();
                        },
                      ),
                    ),
                    activeChild: SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _mnController,
                        decoration: InputDecoration(
                          hintText: 'Middle Name',
                          filled: true,
                          fillColor: Theme.of(context).canvasColor,
                        ),
                        onSubmitted: (_) {
                          // key.currentState?.next();
                          WizardScope.of(context).next();
                        },
                      ),
                    ),
                  ),
                  Wizard(
                    overlays: [
                      WizardOverlay(
                        alignment: Alignment(-.3, -1),
                        child: Text(
                          'This can be anything',
                          style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontSize: 24),
                        ),
                      ),
                      WizardOverlay(
                        alignment: Alignment(.6, -1),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_circle_down,
                              color: Colors.pink,
                            ),
                            Icon(
                              Icons.safety_divider_outlined,
                              color: Colors.blueGrey,
                            ),
                            Icon(
                              Icons.yard,
                              color: Colors.orange,
                            ),
                            Icon(
                              Icons.view_carousel_outlined,
                              color: Colors.blue,
                            ),
                            Icon(
                              Icons.e_mobiledata,
                              color: Colors.cyan,
                            ),
                          ],
                        ),
                      ),
                      WizardOverlay(
                        child: _InfoCard(label: 'Enter your last name here'),
                      ),
                    ],
                    background: background,
                    child: SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _lnController,
                        decoration: InputDecoration(hintText: 'Last Name'),
                        onSubmitted: (_) {
                          // key.currentState?.next();
                          WizardScope.of(context).next();
                        },
                      ),
                    ),
                    activeChild: SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _lnController,
                        decoration: InputDecoration(
                          hintText: 'Last Name',
                          filled: true,
                          fillColor: Theme.of(context).canvasColor,
                        ),
                        onSubmitted: (_) {
                          // key.currentState?.next();
                          WizardScope.of(context).next();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Wizard(
                    overlays: [
                      WizardOverlay(
                        alignment: Alignment(-0.5, 1),
                        child: _InfoCard(label: 'Click on submit to proceed'),
                      ),
                      WizardOverlay(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          height: 100,
                          child: Image.network(
                            'https://pngimg.com/uploads/mario/mario_PNG57.png',
                          ),
                        ),
                      ),
                    ],
                    background: background,
                    child: ElevatedButton(
                      onPressed: () {
                        WizardScope.of(context).next();
                      },
                      child: Text('Submit'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, Key? key}) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
