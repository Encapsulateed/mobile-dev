import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';


 List<MyPoint> marks = [
  MyPoint("Сервисный центр Nissan Нижегородец", 55.854265, 38.511542),
  MyPoint("Favorit Auto Автосервис", 55.842593, 38.431017),
  MyPoint("Экосервис", 55.856846, 38.437501),
  MyPoint("StarLine", 55.774138, 38.451261),
];

class MyPoint {
  final String name;
  final double latitude;
  final double longitude;

  const MyPoint(this.name, this.latitude,this.longitude);
}


Future<List<MyPoint>> parsePoints() async {
  final Dio dio = Dio();

  final response = await dio.get(
      'http://pstgu.yss.su/iu9/mobiledev/lab4_yandex_map/2023.php?x=var15');

    final List<dynamic> data =  jsonDecode(response.data);

    var lst =  data.map((item) {
      final gps = item['gps'].split(',');
      final latitude = double.parse(gps[0].trim());
      final longitude = double.parse(gps[1].trim());
      return MyPoint(item['name'], latitude, longitude);
    }).toList();

    print(lst.length);
    return lst;
}


