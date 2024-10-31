import 'dart:convert';
import 'dart:io';

const String filePath = 'number.json';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8000);
  print('WebSocket server is listening on ws://localhost:8000');

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request))
      WebSocketTransformer.upgrade(request).then(handleWebSocket);
  }
}

void handleWebSocket(WebSocket socket) {
  socket.listen((message) async {
    Map<String, dynamic> data = jsonDecode(message);

    if (data['action'] == 'setNumber' && data.containsKey('number')) {
      final int number = data['number'];
      await setNumber(number);
      print("Num saved: $number");
      socket.add(jsonEncode({'status': 'ok', 'message': 'Num saved: $number'}));
    } else if (data['action'] == 'getNumber') {
      int number = await getNumber();
      print("Num retrieved: $number");
      socket.add(jsonEncode({'status': 'ok', 'number': number}));
    }
  });
}

Future<void> setNumber(int number) async {
  await File(filePath).writeAsString(jsonEncode({'number': number}));
}

Future<int> getNumber() async {
  if (await File(filePath).exists()) {
    String content = await File(filePath).readAsString();
    Map<String, dynamic> data = jsonDecode(content);
    return data['number'] ?? 0;
  } else {
    return 0;
  }
}
