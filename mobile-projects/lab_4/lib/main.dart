import 'package:flutter/material.dart';
import 'pages/lab2_page.dart';
import 'pages/lab3_page.dart';
import 'pages/parabola.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/parabola',
      routes: {
        '/parabola': (context) => ParabolaAnimationScreen(),
        '/lab2': (context) => Lab2Screen(),
        '/lab3': (context) => Lab3Screen(),
      },
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter App with Sidebar Menu"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
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
          ],
        ),
      ),
      body: Center(
        child: Text('Выберите пункт меню'),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 18)),
      onTap: () {
        Navigator.pop(context); // Закрываем Drawer
        Navigator.pushNamed(context, route); // Переходим по маршруту
      },
    );
  }
}
