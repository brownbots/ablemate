import 'package:flutter/material.dart';
import 'routes.dart';

void main() {
  runApp(const AbleMateApp());
}

class AbleMateApp extends StatelessWidget {
  const AbleMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AbleMate',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/get-started',
      routes: appRoutes,
    );
  }
}
