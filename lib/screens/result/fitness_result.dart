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
  final double confidence; // Confidence directly here

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
    required String suggestions, // Remove suggestions
  });

  // Updated toJson method without passing confidenceScore as dynamic
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
      'confidence': confidence, // Now just use the confidence value directly
    };
  }

  // Updated fromJson to properly extract confidence from JSON
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
      suggestions: '', // Extract confidence correctly
    );
  }
}
