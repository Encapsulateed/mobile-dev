import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WS_Screen extends StatelessWidget {
  const WS_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WS Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NumberForm(),
    );
  }
}

class NumberForm extends StatefulWidget {
  const NumberForm({super.key});

  @override
  _NumberFormState createState() => _NumberFormState();
}

class _NumberFormState extends State<NumberForm> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  int _currentNumber = 0;

  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();

    try {
      _channel = IOWebSocketChannel.connect('ws://192.168.191.18:8000');
    } catch (e) {
      print("Error in WebSocket connection: $e");
    }
  }

  void sendNumber(int number) {
    final data = jsonEncode({
      'action': 'setNumber',
      'number': number,
    });
    print("Sending number: $number");
    _channel.sink.add(data);
  }

  void getNumber() {
    final data = jsonEncode({
      'action': 'getNumber',
    });
    _channel.sink.add(data);
  }

  void increment() {
    setState(() {
      _currentNumber++;
    });
    sendNumber(_currentNumber);
  }

  void decrement() {
    setState(() {
      _currentNumber--;
    });
    sendNumber(_currentNumber);
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WS Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Запишите число'),
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
                    final number = int.parse(_numberController.text);
                    sendNumber(number);
                  }
                },
                child: const Text('Отправить'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: getNumber,
                child: const Text('Получить число'),
              ),
              const SizedBox(height: 20),
              Text('Current: $_currentNumber', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: decrement,
                    child: const Text('Уменьшить'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: increment,
                    child: const Text('Увеличить'),
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
