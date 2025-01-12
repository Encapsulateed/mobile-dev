import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

const double G = 6.67430e-5; // Гравитационная постоянная

void main() {
  runApp(GravityApp());
}

class GravityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Сближение сфер',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black, // Темный фон
      ),
      home: GravityHomePage(),
    );
  }
}

class GravityHomePage extends StatefulWidget {
  @override
  _GravityHomePageState createState() => _GravityHomePageState();
}

class _GravityHomePageState extends State<GravityHomePage> {
  final _formKey = GlobalKey<FormState>();

  double mass1 = 1.0; // В миллионах тонн
  double mass2 = 1.0; // В миллионах тонн
  double initialDistance = 100.0; // Начальное расстояние

  double radius1 = 10.0;
  double radius2 = 10.0;

  bool isAnimating = false;

  late Scene _scene;
  late Object _sphere1;
  late Object _sphere2;

  Vector3 sphere1Pos = Vector3(50, 0, 0);
  Vector3 sphere2Pos = Vector3(-50, 0, 0);
  Vector3 sphere1Velocity = Vector3(0, 0, 0);
  Vector3 sphere2Velocity = Vector3(0, 0, 0);

  late Timer _timer;

  void _onSceneCreated(Scene scene) {
    _scene = scene;
    scene.camera.position.z = 100; // Позиция камеры

    _sphere1 = Object(
      position: sphere1Pos,
      scale: Vector3(radius1, radius1, radius1),
      fileName: 'lib/assets/sphere.obj', // Путь до ассета
    );

    _sphere2 = Object(
      position: sphere2Pos,
      scale: Vector3(radius2, radius2, radius2),
      fileName: 'lib/assets/sphere.obj', // Путь до ассета
    );

    _scene.world.add(_sphere1);
    _scene.world.add(_sphere2);
  }

  void _updateSpherePositions() {
    double dist = (sphere1Pos - sphere2Pos).length;

    // Минимальное расстояние между сферами (радиус+радиус)
    double minDistance = radius1 + radius2;

    if (dist <= minDistance) {
      // Если сферы столкнулись (расстояние меньше суммы радиусов)
      dist = minDistance;
      sphere1Velocity = Vector3(0, 0, 0);
      sphere2Velocity = Vector3(0, 0, 0);
      _timer.cancel();
      isAnimating = false;
      return;
    }

    // Расчёт массы в килограммах (массы в миллионах тонн)
    double m1 = mass1 * 1e9;
    double m2 = mass2 * 1e9;

    // Расчёт гравитационной силы
    double force = G * m1 * m2 / (dist * dist);
    Vector3 direction = (sphere2Pos - sphere1Pos).normalized();

    // a = F / m (ускорение = сила / масса)
    Vector3 acceleration1 = direction * (force / m1);
    Vector3 acceleration2 = -direction * (force / m2);

    // Обновление скорости и позиции сфер
    sphere1Velocity += acceleration1 * 0.02; // Шаг времени
    sphere2Velocity += acceleration2 * 0.02; // Шаг времени

    sphere1Pos += sphere1Velocity * 0.02; // Шаг времени
    sphere2Pos += sphere2Velocity * 0.02; // Шаг времени

    // Обновление позиции сфер в сцене
    _sphere1.position.setValues(sphere1Pos.x, sphere1Pos.y, sphere1Pos.z);
    _sphere2.position.setValues(sphere2Pos.x, sphere2Pos.y, sphere2Pos.z);

    _sphere1.updateTransform();
    _sphere2.updateTransform();
  }

  // Метод для запуска симуляции
  void startSimulation() {
    setState(() {
      radius1 = pow(mass1, 1 / 3) * 4;
      radius2 = pow(mass2, 1 / 3) * 4;

      isAnimating = true;

      // Устанавливаем начальные позиции сфер
      sphere1Pos = Vector3(initialDistance / 2, 0, 0);
      sphere2Pos = Vector3(-initialDistance / 2, 0, 0);

      // Начальная скорость
      sphere1Velocity = Vector3(0, 0, 0);
      sphere2Velocity = Vector3(0, 0, 0);

      // Запуск таймера для обновления положения
      _timer = Timer.periodic(Duration(milliseconds: 20), (timer) {
        _updateSpherePositions();
        _scene.update();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сближение сфер'),
      ),
      body: Stack(
        children: [
          // Визуализация сцены с кубами
          isAnimating
              ? Cube(
            onSceneCreated: _onSceneCreated,
          )
              : Cube(
            onSceneCreated: (scene) {
              _onSceneCreated(scene);
            },
          ),

          // Элементы управления внизу
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ползунок для массы первой сферы
                  Text('Масса первой сферы: ${mass1.toStringAsFixed(2)} млн. тонн'),
                  Slider(
                    value: mass1,
                    min: 0.1,
                    max: 10.0,
                    divisions: 99,
                    label: mass1.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        mass1 = value;
                      });
                    },
                  ),

                  SizedBox(height: 20),

                  // Ползунок для массы второй сферы
                  Text('Масса второй сферы: ${mass2.toStringAsFixed(2)} млн. тонн'),
                  Slider(
                    value: mass2,
                    min: 0.1,
                    max: 10.0,
                    divisions: 99,
                    label: mass2.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        mass2 = value;
                      });
                    },
                  ),

                  SizedBox(height: 20),

                  // Ползунок для начального расстояния
                  Text('Начальное расстояние: ${initialDistance.toStringAsFixed(2)} ед.',
                      style: TextStyle(fontSize: 16)),
                  Slider(
                    value: initialDistance,
                    min: 10.0,
                    max: 200.0,
                    divisions: 190,
                    label: initialDistance.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        initialDistance = value;
                      });
                    },
                  ),

                  SizedBox(height: 30),

                  // Кнопка для запуска симуляции
                  ElevatedButton(
                    onPressed: () {
                      startSimulation();
                    },
                    child: Text('Начать симуляцию'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
