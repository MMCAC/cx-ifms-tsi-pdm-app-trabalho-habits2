// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho/controllers/SettingsController.dart';
import 'package:trabalho/pages/todosConcluidosPage.dart';
import 'package:trabalho/pages/todosHabitos.dart';
import 'pages/homePage.dart';
import 'pages/habitFormPage.dart';
import 'pages/progressoPage.dart';
import 'pages/settingsPage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
    create: (_) => SettingsController(),
    child: HabitApp(),
  ),);
}

class HabitApp extends StatefulWidget{
  // const HabitApp({super.key});

  @override
  State<HabitApp> createState() => _HabitAppState();
}

class _HabitAppState extends State<HabitApp> {

  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(){
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      title: 'Controle de Hábitos',
      initialRoute: "/",
      routes: {
        '/': (context) => HomePage(toggleTheme: _toggleTheme),
        '/formHabit': (context) => HabitFormPage(),
        '/settings': (context) =>  SettingsPage(),
        '/progress': (context) =>  ProgressoPage(),
        '/todosHabitos': (context) => TodosHabitosPage(),
        '/concluidos': (context) => TodosConcluidosPage(),
      },
    );
  }
}
