import 'package:fitlyzer/screens/report/report_screen.dart';
import 'package:flutter/material.dart';

class FitnessResult {
  final String ageGroup;
  final double bmi;
  final String exercises;
  final String equipment;
  final String diet;
  final String recommendation;
  final DateTime timestamp;

  FitnessResult({
    required this.ageGroup,
    required this.bmi,
    required this.exercises,
    required this.equipment,
    required this.diet,
    required this.recommendation,
    required this.timestamp,
  });
}

class ResultScreen extends StatelessWidget {
  final String ageGroup;
  final double bmi;
  final String exercises;
  final String equipment;
  final String diet;
  final String recommendation;

  const ResultScreen({
    super.key,
    required this.ageGroup,
    required this.bmi,
    required this.exercises,
    required this.equipment,
    required this.diet,
    required this.recommendation,
  });

  void _saveToHistory(BuildContext context) {
    final result = FitnessResult(
      ageGroup: ageGroup,
      bmi: bmi,
      exercises: exercises,
      equipment: equipment,
      diet: diet,
      recommendation: recommendation,
      timestamp: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => const ReportScreen(reportHistory: [], history: []),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Fitness Plan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Fitness Plan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard('Age Group', ageGroup),
            _buildInfoCard('BMI', bmi.toStringAsFixed(2)),
            _buildInfoCard('Exercises', exercises),
            _buildInfoCard('Equipment', equipment),
            _buildInfoCard('Diet', diet),
            _buildInfoCard('Recommendation', recommendation),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () => _saveToHistory(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save to History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
