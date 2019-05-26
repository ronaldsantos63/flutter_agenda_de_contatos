import 'package:flutter/material.dart';
import 'package:flutter_agenda_de_contatos/ui/home_page.dart';

void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    showSemanticsDebugger: false,
    title: "Agenda de Contatos",
    theme: ThemeData(
      primaryColor: Colors.green.shade800,
      accentColor: Colors.green,
      hintColor: Colors.green.shade300,

      fontFamily: 'Montserrat',

//      textTheme: TextTheme(
//        headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
//        title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
//        body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
//      ),

      unselectedWidgetColor: Colors.green.shade300,
      disabledColor: Colors.green.shade300,
      iconTheme: IconThemeData(color: Colors.greenAccent,),
      accentIconTheme: IconThemeData(color: Colors.green.shade300),
      highlightColor: Colors.green.shade300,
      cursorColor: Colors.green,
      textSelectionColor: Colors.greenAccent,
      //primaryIconTheme: IconThemeData(color: Colors.green.shade300),
    ),
    home: HomePage(),
  ));
}