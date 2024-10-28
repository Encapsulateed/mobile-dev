import 'package:flutter/material.dart';
import 'pages/lab2_page.dart';
import 'pages/lab3_page.dart';
import 'pages/parabola.dart';
import 'pages/lab5_page.dart';
import 'pages/fly_my_sql.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/parabola',
      routes: {
        '/parabola': (context) => const BaseScaffold(child: ParabolaAnimationScreen()),
        '/lab2': (context) => const BaseScaffold(child: Lab2Screen()),
        '/lab3': (context) => const BaseScaffold(child: Lab3Screen()),
        '/lab5': (context) => const BaseScaffold(child: Lab5Screen()),
        '/fly_my_sql' : (context) => const BaseScaffold(child: MySqlScreen())
      },
      home: const BaseScaffold(child: HomeScreen()),
    );
  }
}

// Базовый виджет с боковым меню
class BaseScaffold extends StatelessWidget {
  final Widget child;

  const BaseScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.greenAccent,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            _buildDrawerItem(context, 'Parabola Animation', '/parabola'),
            _buildDrawerItem(context, 'Lab 2', '/lab2'),
            _buildDrawerItem(context, 'Lab 3', '/lab3'),
            _buildDrawerItem(context, 'Lab 5', '/lab5'),
            _buildDrawerItem(context, 'Fly MySQL', '/fly_my_sql'),
          ],
        ),
      ),
      body: child,
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}

// Главная страница
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Пожалуйста выберите какой-то пункт'),
    );
  }
}
