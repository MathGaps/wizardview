import 'package:flutter/material.dart';
import 'package:wizardview/wizardview.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter(BuildContext context) {
    WizardScope.of(context).next();
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WizardScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
              Wizard(
                child: Text(
                  '$_counter',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.red),
                ),
                background: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.blue,
                ),
                overlay: Container(
                  color: Colors.yellow.withOpacity(0.5),
                  height: 50,
                  width: 50,
                ),
              ),
              Wizard(
                child: Text(
                  '$_counter + 1',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.green),
                ),
                background: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.red,
                ),
                overlay: Container(
                  color: Colors.yellow.withOpacity(0.2),
                  height: 50,
                  width: 300,
                ),
              ),
            ],
          ),
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
