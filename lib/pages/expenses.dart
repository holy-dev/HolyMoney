import 'package:flutter/material.dart';
import 'package:holy_money/widgets/header.dart';

class Expenses extends StatefulWidget {

  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
       appBar: header(context, isAppTitle: true, appTitle: 'Expenses'),
       body: ListView(
         children: <Widget>[
           Column(
             mainAxisAlignment: MainAxisAlignment.end,
             //crossAxisAlignment: CrossAxisAlignment.end,
             children: <Widget>[
              
             ],
           ),
         ],
       ),
    );
  }
}