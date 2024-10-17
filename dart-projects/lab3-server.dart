import 'dart:convert';
import 'dart:io';

const String filePath = 'number.json';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8000);

  print('now listening on http://localhost:8000');

  await for (HttpRequest request in server) {
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers
        .add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers
        .add('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      request.response
        ..statusCode = HttpStatus.ok
        ..close();
      continue;
    }
    if (request.method == 'POST' && request.uri.path == '/setNumber') {
      await handlePost(request);
    } else if (request.method == 'GET' && request.uri.path == '/getNumber') {
      await handleGet(request);
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('404 - Not Found')
        ..close();
    }
  }
}

Future<void> handlePost(HttpRequest request) async {
  try {
    String content = await utf8.decoder.bind(request).join();
    Map<String, dynamic> data = jsonDecode(content);
    if (data.containsKey('number') && data['number'] is int) {
      await File(filePath)
          .writeAsString(jsonEncode({'number': data['number']}));

      request.response
        ..statusCode = HttpStatus.ok
        ..write('OK');
    } else {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Ошибка: поле "number" отсутствует или неверного типа');
    }
  } catch (e) {
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write('Ошибка сервера: $e');
  } finally {
    await request.response.close();
  }
}

Future<void> handleGet(HttpRequest request) async {
  try {
    if (await File(filePath).exists()) {
      String content = await File(filePath).readAsString();
      Map<String, dynamic> data = jsonDecode(content);
      int number = data['number'] ?? 0;

      request.response
        ..statusCode = HttpStatus.ok
        ..write(jsonEncode({'number': number}));
    } else {
      request.response
        ..statusCode = HttpStatus.ok
        ..write(jsonEncode({'number': 0}));
    }
  } catch (e) {
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write('Ошибка сервера: $e');
  } finally {
    await request.response.close();
  }
}
