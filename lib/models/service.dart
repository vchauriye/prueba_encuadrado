import 'dart:convert';

import 'package:flutter/material.dart';

class Service {
  final String name;
  final double price;
  final String day;
  final String startTime;
  final String endTime;
  final int minDuration;
  final int maxDuration;
  List<TimeOfDay> availableHours;

  Service({
    required this.name,
    required this.price,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.minDuration,
    required this.maxDuration,
    this.availableHours = const [],
  });

   void updateAvailability(TimeOfDay bookedStartTime, TimeOfDay bookedEndTime) {
    final bookedTime = TimeOfDayRange(bookedStartTime, bookedEndTime);
    availableHours.removeWhere((time) => bookedTime.isWithin(time));
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'minDuration': minDuration,
      'maxDuration': maxDuration,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      name: map['name'],
      price: map['price'],
      day: map['day'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      minDuration: map['minDuration'],
      maxDuration: map['maxDuration'],
    );
  }

  String toJson() {
    final map = toMap();
    return json.encode(map);
  }

  factory Service.fromJson(String jsonString) {
    final map = json.decode(jsonString);
    return Service.fromMap(map);
  }
}
class TimeOfDayRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeOfDayRange(this.start, this.end);

  bool isWithin(TimeOfDay time) {
    final timeInMinutes = time.hour * 60 + time.minute;
    final startInMinutes = start.hour * 60 + start.minute;
    final endInMinutes = end.hour * 60 + end.minute;
    return timeInMinutes >= startInMinutes && timeInMinutes <= endInMinutes;
  }
}
