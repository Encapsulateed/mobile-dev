import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Lab3Screen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab3',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NumberForm(),
    );
  }
}

class NumberForm extends StatefulWidget {
  @override
  _NumberFormState createState() => _NumberFormState();
}

class _NumberFormState extends State<NumberForm> {
  final URL = 'http://127.0.0.1:8080';

  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  int _currentNumber = 0;

  Future<void> sendNumber() async {
    final url = Uri.parse('${URL}/setNumber');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'number': _currentNumber,
      }),
    );

    if (response.statusCode == 200) {
      print('Num sent: ${_currentNumber}');
    } else {
      print('Error: ${response.statusCode}');
    }
  }
  Future<void> sendNumberFromNumberController() async {
    final url = Uri.parse('${URL}/setNumber');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'number': int.parse(_numberController.text),
      }),
    );

    if (response.statusCode == 200) {
      print('Num sent: ${_numberController.text}');
    } else {
      print('Error: ${response.statusCode}');
    }
  }
//${URL}
  Future<void> getNumber() async {
    final url = Uri.parse('${URL}/getNumber');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      setState(() {
        _currentNumber = jsonResponse['number'] as int;
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void increment() {
    setState(() {
      _currentNumber++;
    });

    sendNumber();
  }

  void decrement() {
    setState(() {
      _currentNumber--;
    });

    sendNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab3'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _numberController,
                decoration: InputDecoration(labelText: 'Запишите число'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Запишите число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    sendNumberFromNumberController();
                  }
                },
                child: Text('Отправить'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: getNumber,
                child: Text('Получить число'),
              ),
              const SizedBox(height: 20),
              Text('Current: $_currentNumber', style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: decrement,
                    child: Text('Уменьшить'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: increment,
                    child: Text('Увеличить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}