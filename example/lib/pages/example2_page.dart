import 'package:example/pages/example2_body.dart';
import 'package:flutter/material.dart';
import 'package:wizardview/wizardview.dart';

class Example2Page extends StatefulWidget {
  Example2Page({Key? key}) : super(key: key);

  @override
  _Example2PageState createState() => _Example2PageState();
}

class _Example2PageState extends State<Example2Page> {
  final GlobalKey<WizardScopeState> key = GlobalKey<WizardScopeState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      showInfoDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WizardView Example2'),
      ),
      body: WizardScope(
        key: key,
        child: Example2Body(),
        background: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.amber,
        ),
        onEnd: (state) => showCongratulationsDialog(),
      ),
    );
  }

  void showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text('Please fill in the required details'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              key.currentState?.next();
            },
            child: Text('Okay'),
          )
        ],
      ),
    );
  }

  showCongratulationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Congratulations!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Okay'),
          )
        ],
      ),
    );
  }
}