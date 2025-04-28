import 'dart:io';
import 'package:flutter/material.dart';
import './../report/fitness_result.dart';

class ReportScreen extends StatelessWidget {
  final List<FitnessResult> history;

  const ReportScreen({
    Key? key,
    required this.history,
    required List reportHistory, // Only the 'history' list is needed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Report History')),
      body:
          history.isEmpty
              ? const Center(child: Text('No reports available'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final result = history[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report from ${result.timestamp.toString().substring(0, 16)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (File(result.imagePath).existsSync())
                            Image.file(
                              File(result.imagePath),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          else
                            const Text('Image not available'),
                          const SizedBox(height: 10),
                          Text('Body Type: ${result.bodyType}'),
                          Text(
                            'Confidence: ${result.confidence.toStringAsFixed(2)}',
                          ),
                          Text('BMI: ${result.bmi.toStringAsFixed(2)}'),
                          Text('Age Group: ${result.ageGroup}'),
                          const SizedBox(height: 10),
                          const Text(
                            'Exercises:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(result.exercises),
                          const SizedBox(height: 10),
                          const Text(
                            'Equipment:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(result.equipment),
                          const SizedBox(height: 10),
                          const Text(
                            'Diet Plan:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(result.diet),
                          const SizedBox(height: 10),
                          const Text(
                            'Recommendation:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(result.recommendation),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
