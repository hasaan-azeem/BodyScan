// ignore_for_file: unused_import

import 'package:flutter/foundation.dart';

class FitnessResult {
  final String ageGroup;
  final double bmi;
  final String exercises;
  final String equipment;
  final String diet;
  final String recommendation;
  final DateTime timestamp;
  final String imagePath;
  final String bodyType;
  final double confidence;

  FitnessResult({
    required this.ageGroup,
    required this.bmi,
    required this.exercises,
    required this.equipment,
    required this.diet,
    required this.recommendation,
    required this.timestamp,
    required this.imagePath,
    required this.bodyType,
    required this.confidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'ageGroup': ageGroup,
      'bmi': bmi,
      'exercises': exercises,
      'equipment': equipment,
      'diet': diet,
      'recommendation': recommendation,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
      'bodyType': bodyType,
      'confidence': confidence,
    };
  }

  factory FitnessResult.fromJson(Map<String, dynamic> json) {
    return FitnessResult(
      ageGroup: json['ageGroup'],
      bmi: json['bmi'],
      exercises: json['exercises'],
      equipment: json['equipment'],
      diet: json['diet'],
      recommendation: json['recommendation'],
      timestamp: DateTime.parse(json['timestamp']),
      imagePath: json['imagePath'],
      bodyType: json['bodyType'],
      confidence: json['confidence'],
    );
  }
}
