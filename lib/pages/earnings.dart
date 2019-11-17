import 'package:flutter/material.dart';
import 'package:holy_money/widgets/header.dart';

class Earnings extends StatefulWidget {
  Earnings({Key key}) : super(key: key);

  @override
  _EarningsState createState() => _EarningsState();
}

class _EarningsState extends State<Earnings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
       appBar: header(context, isAppTitle: true, appTitle: 'Earnings'),
    );
  }
}