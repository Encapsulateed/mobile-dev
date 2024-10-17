import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Lab2Screen extends StatelessWidget {
  const Lab2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SwitchControl(),
    );
  }
}

class SwitchControl extends StatefulWidget {
  const SwitchControl({super.key});

  @override
  _SwitchControlState createState() => _SwitchControlState();
}

class _SwitchControlState extends State<SwitchControl> {
  bool _isOn = false;

  Future<void> _toggleSwitch(bool value) async {
    setState(() {
      _isOn = value;
    });

    final url = Uri.parse('http://iocontrol.ru/api/sendData/tested/on_off/${_isOn ? '1' : '0'}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ответ сервера: ${response.body}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${response.statusCode} ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 2 - Switch Control'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Переключатель состояния',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Состояние'),
                    value: _isOn,
                    onChanged: (value) {
                      _toggleSwitch(value);
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
