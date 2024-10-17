import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

const broker = 'test.mosquitto.org';
const port = 1883;

class Lab5Screen extends StatelessWidget {
  const Lab5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MqttApp(),
    );
  }
}

class MqttApp extends StatefulWidget {
  const MqttApp({super.key});

  @override
  _MqttAppState createState() => _MqttAppState();
}

class _MqttAppState extends State<MqttApp> {
  final client = MqttServerClient.withPort(broker, 'flutter_mqtt_client', port);
  final textController1 = TextEditingController();
  final textController2 = TextEditingController();
  final textController3 = TextEditingController();

  Map<String, String> receivedMessages = {
    'topic1': '',
    'topic2': '',
    'topic3': '',
  };

  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _setupMqttClient();
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  Future<void> _setupMqttClient() async {
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.setProtocolV311();
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;

    try {
      await client.connect();
    } on Exception catch (e) {
      print('Ошибка подключения: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Подключение установлено');
      _subscribeToTopics();
    } else {
      print('Ошибка подключения');
    }
  }

  void _onConnected() {
    print('MQTT-клиент подключен');
    setState(() {
      _isConnected = true;
    });
    _subscribeToTopics();
  }

  void _onDisconnected() {
    print('MQTT-клиент отключен');
    setState(() {
      _isConnected = false;
    });
  }

  void _subscribeToTopics() {
    if (_isConnected) {
      client.subscribe('flutter/topic1', MqttQos.atLeastOnce);
      client.subscribe('flutter/topic2', MqttQos.atLeastOnce);
      client.subscribe('flutter/topic3', MqttQos.atLeastOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
        final message = messages![0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);

        setState(() {
          receivedMessages[messages[0].topic.split('/').last] = payload;
        });
      });
    }
  }

  void _publishMessage(String topic, String message) {
    if (_isConnected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      print('Клиент не подключен. Невозможно отправить сообщение.');
    }
  }

  void _sendMessages() {
    _publishMessage('flutter/topic1', textController1.text);
    _publishMessage('flutter/topic2', textController2.text);
    _publishMessage('flutter/topic3', textController3.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MQTT Client')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: textController1,
              decoration: const InputDecoration(labelText: 'Введите значение для Topic 1'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: textController2,
              decoration: const InputDecoration(labelText: 'Введите значение для Topic 2'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: textController3,
              decoration: const InputDecoration(labelText: 'Введите значение для Topic 3'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isConnected ? _sendMessages : null,
              child: const Text('Отправить данные'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Полученные сообщения (JSON):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              receivedMessages.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
