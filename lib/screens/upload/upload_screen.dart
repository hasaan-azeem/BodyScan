// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:fitlyzer/globals.dart';
import 'package:fitlyzer/screens/result/fitness_result.dart';
import 'package:fitlyzer/screens/report/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  final picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  // String? _sex;
  String? _age;
  String? _height;
  String? _weight;
  String? _diabetes;
  String? _hypertension;

  bool _loading = false;
  Map<String, dynamic>? _resultData;

  List<FitnessResult> _reportHistory = [];
  FitnessResult? _latestResult;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> predictBodyType(String imagePath) async {
    const apiKey = "2a6f941c61c44cc1ae55e7bcd45af7fd";
    const userId = "areesha555";
    const appId = "BodyClassifier";
    const modelId = "BodyclassifierFinal1";

    final bytes = await _image!.readAsBytes();
    final base64Image = base64Encode(bytes);

    final body = jsonEncode({
      "inputs": [
        {
          "data": {
            "image": {"base64": base64Image},
          },
        },
      ],
    });

    final url =
        'https://api.clarifai.com/v2/users/$userId/apps/$appId/models/$modelId/outputs';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Key $apiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final concepts = result['outputs'][0]['data']['concepts'];
      final bestMatch = concepts.reduce(
        (a, b) => a['value'] > b['value'] ? a : b,
      );

      final bodyType = bestMatch['name'];
      final confidenceScore = bestMatch['value'];

      if (concepts != null && concepts.isNotEmpty) {
        concepts.sort(
          (a, b) => (b['value'] as double).compareTo(a['value'] as double),
        );

        final top = concepts.first;
        final name = top['name'];
        final confidence = top['value'];

        setState(() {
          _resultData = {
            'Body_type': name,
            'Confidence': (confidence * 100).toStringAsFixed(2) + '%',
          };
        });

        return name;
      }
    } else {
      print('Failed to predict body type: ${response.body}');
    }
    return null;
  }

  Future<Map<String, dynamic>?> findMatchingData(String bodyType) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/fitness_data.json',
      );
      final List<dynamic> data = jsonDecode(jsonString);

      for (var item in data) {
        if (item['Body_type'].toString().toLowerCase() ==
            bodyType.toLowerCase()) {
          return item as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print("Error loading or parsing JSON: $e");
      return null;
    }
  }

  Future<void> uploadAndAnalyze() async {
    if (_formKey.currentState!.validate() && _image != null) {
      _formKey.currentState!.save();
      setState(() {
        _loading = true;
      });

      String? bodyType = await predictBodyType(_image!.path);

      if (bodyType == null) {
        final double parsedHeight = double.tryParse(_height ?? '') ?? 1.0;
        final double parsedWeight = double.tryParse(_weight ?? '') ?? 1.0;
        final double bmi = parsedWeight / (parsedHeight * parsedHeight);

        calculateBMI(parsedWeight, parsedHeight);

        if (bmi < 18.5) {
          bodyType = "Underweight";
        } else if (bmi >= 18.5 && bmi < 25) {
          bodyType = "Fit";
        } else if (bmi >= 25 && bmi < 35) {
          bodyType = "Muscular";
        } else {
          bodyType = "Overweight";
        }
      }

      var data = await findMatchingData(bodyType);

      data ??= {
        'Body_type': bodyType,
        'Exercises': 'Basic exercises suitable for your body type.',
        'Diet': 'A healthy diet tailored to your BMI.',
        'Recommendation': 'General recommendation based on your body type.',
        'Fitness_Goal': 'Maintain health and fitness.',
        'Fitness_Type': 'General fitness.',
        'Equipment': 'No specific equipment needed.',
      };

      final double parsedHeight = double.tryParse(_height ?? '') ?? 1.0;
      final double parsedWeight = double.tryParse(_weight ?? '') ?? 1.0;
      final double bmi = calculateBMI(parsedWeight, parsedHeight);

      final double confidenceScore =
          double.tryParse(
            _resultData!['Confidence'].toString().replaceAll('%', ''),
          )! /
          100;

      final fitnessResult = FitnessResult(
        ageGroup: _age ?? "Unknown",
        bmi: bmi,
        exercises: data['Exercises'] ?? '',
        equipment: data['Equipment'] ?? '',
        diet: data['Diet'] ?? '',
        recommendation: data['Recommendation'] ?? '',
        timestamp: DateTime.now(),
        imagePath: _image!.path,
        bodyType: data['Body_type'] ?? '',
        confidence: confidenceScore,
        suggestions: '',
      );

      setState(() {
        _loading = false;
        _resultData?.addAll(data!);
        _latestResult = fitnessResult;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and pick an image'),
        ),
      );
    }
  }

  void addResultToHistory() {
    if (_latestResult != null) {
      setState(() {
        globalReportHistory.add(_latestResult!);
        _latestResult = null;
        _resultData = null;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ReportScreen(
                reportHistory: globalReportHistory,
                history: globalReportHistory,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload and Analyze')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child:
                          _image != null
                              ? Image.file(
                                _image!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              )
                              : Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.camera_alt, size: 50),
                              ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildTextField(
                            "Age",
                            (val) => _age = val,
                            isNumber: true,
                          ),
                          buildTextField(
                            "Height (m)",
                            (val) => _height = val,
                            isNumber: true,
                          ),
                          buildTextField(
                            "Weight (kg)",
                            (val) => _weight = val,
                            isNumber: true,
                          ),
                          buildRadioGroup(
                            "Diabetes",
                            (val) => _diabetes = val,
                            _diabetes,
                          ),
                          buildRadioGroup(
                            "Hypertension",
                            (val) => _hypertension = val,
                            _hypertension,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: uploadAndAnalyze,
                      child: const Text('Analyze'),
                    ),
                    const SizedBox(height: 30),
                    if (_resultData != null) ...[
                      buildResultSection(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: addResultToHistory,
                        child: const Text('Save to History'),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget buildTextField(
    String label,
    Function(String) onSaved, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Required';
          return null;
        },
        onSaved: (value) => onSaved(value ?? ''),
      ),
    );
  }

  Widget buildRadioGroup(
    String label,
    Function(String) onChanged,
    String? groupValue,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Yes'),
                  value: 'Yes',
                  groupValue: groupValue,
                  onChanged: (val) => setState(() => onChanged(val!)),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('No'),
                  value: 'No',
                  groupValue: groupValue,
                  onChanged: (val) => setState(() => onChanged(val!)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Result:",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text("Body Type: ${_resultData!['Body_type']}"),
        if (_resultData!.containsKey('Confidence'))
          Text("Confidence: ${_resultData!['Confidence']}"),
        Text("Fitness Goal: ${_resultData!['Fitness_Goal']}"),
        Text("Fitness Type: ${_resultData!['Fitness_Type']}"),
        Text("Exercises: ${_resultData!['Exercises']}"),
        Text("Equipment: ${_resultData!['Equipment']}"),
        const SizedBox(height: 10),
        const Text(
          "Diet Plan:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text("${_resultData!['Diet']}"),
        const SizedBox(height: 10),
        const Text(
          "Recommendation:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text("${_resultData!['Recommendation']}"),
      ],
    );
  }
}

double calculateBMI(double weight, double height) {
  return weight / (height * height);
}
