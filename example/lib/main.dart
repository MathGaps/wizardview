import 'package:example/pages/home_page.dart';
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
      home: HomePage(title: 'WizardView Example'),
    );
  }
}
