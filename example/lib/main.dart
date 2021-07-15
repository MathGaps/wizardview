import 'package:example/pages/example1_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WizardView Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Example1Page(title: 'WizardView Example'),
      // home: Example2Page(),
    );
  }
}
