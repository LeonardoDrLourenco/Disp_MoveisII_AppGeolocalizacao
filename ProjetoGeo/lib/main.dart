import 'package:projetogeolocalizacao/presentation/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Pontos de Interesse Locais',
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
