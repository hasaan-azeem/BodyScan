import 'dart:io';
import 'package:flutter/material.dart';
import '../result/fitness_result.dart';

class ReportScreen extends StatelessWidget {
  final List<FitnessResult> history;

  const ReportScreen({
    super.key,
    required this.history,
    required List reportHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Report History'),
        // automaticallyImplyLeading: false,
      ),
      body:
          history.isEmpty
              ? const Center(child: Text('No reports available'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final result = history[index];
                  final imageFile = File(result.imagePath);

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📅 Report: ${result.timestamp.toString().substring(0, 16)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              imageFile.existsSync()
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      imageFile,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.broken_image),
                                  ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('🧍 Body Type: ${result.bodyType}'),
                                    // ignore: unnecessary_null_comparison
                                    if (result.confidence != null)
                                      Text(
                                        '🎯 Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
                                      ),
                                    Text(
                                      '📊 BMI: ${result.bmi.toStringAsFixed(2)}',
                                    ),
                                    Text('👥 Age Group: ${result.ageGroup}'),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 24),

                          const Text(
                            '🏋️ Exercises:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(result.exercises),

                          const SizedBox(height: 10),
                          const Text(
                            '🧰 Equipment:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(result.equipment),

                          const SizedBox(height: 10),
                          const Text(
                            '🥗 Diet Plan:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(result.diet),

                          const SizedBox(height: 10),
                          const Text(
                            '📢 Recommendation:',
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
