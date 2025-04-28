// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:fitlyzer/screens/report/fitness_result.dart';
import 'package:fitlyzer/screens/upload/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  double calculateBMI(double weight, double height) {
    return weight / (height * height);
  }

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  final picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  String? _sex;
  String? _age;
  String? _height;
  String? _weight;
  String? _diabetes;
  String? _hypertension;

  bool _loading = false;
  Map<String, dynamic>? _resultData;

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

    final response = await http.post(
      Uri.parse(
        'https://api.clarifai.com/v2/models/BodyclassifierFinal1/versions/latest/outputs',
      ),
      headers: {
        'Authorization': 'Key $apiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final bodyType = result['outputs'][0]['data']['concepts'][0]['name'];
      return bodyType;
    } else {
      print('Failed to predict body type: ${response.body}');
      return null;
    }
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

      // Predict the body type from the image
      String? bodyType = await predictBodyType(_image!.path);

      // If prediction fails, fall back to BMI-based classification
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
          // Assuming "Muscular" for BMI ≥ 25 (you can adjust based on your needs)
          bodyType = "Overweight";
        }
      }

      // Find matching data from the JSON
      var data = await findMatchingData(bodyType);

      // If no matching data, use a default fitness plan
      data ??= {
        'Body_type': bodyType,
        'Exercises': 'Basic exercises suitable for your body type.',
        'Diet': 'A healthy diet tailored to your BMI.',
        'Recommendation': 'General recommendation based on your body type.',
        'Fitness_Goal': 'Maintain health and fitness.',
        'Fitness_Type': 'General fitness.',
        'Equipment': 'No specific equipment needed.',
      };

      // Calculate BMI and prepare the result
      final double parsedHeight = double.tryParse(_height ?? '') ?? 1.0;
      final double parsedWeight = double.tryParse(_weight ?? '') ?? 1.0;
      final double bmi = calculateBMI(parsedWeight, parsedHeight);

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
        confidence: 1.0, // You can calculate confidence if needed
      );

      // Save the result or navigate to another screen
      addResult(fitnessResult);

      setState(() {
        _loading = false;
        _resultData = data;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and pick an image'),
        ),
      );
    }
  }

  void addResult(FitnessResult result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReportScreen(
              // Pass the result to the report screen
              history: [result], // Passing a list with the result
              reportHistory:
                  const [], // You can pass any previous report history if needed
            ),
      ),
    );
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
                          buildDropdownField(),
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
                    if (_resultData != null) buildResultSection(),
                  ],
                ),
              ),
    );
  }

  Widget buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Sex",
        ),
        value: _sex,
        items:
            ['Male', 'Female']
                .map((sex) => DropdownMenuItem(value: sex, child: Text(sex)))
                .toList(),
        onChanged: (val) => setState(() => _sex = val),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
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
          if (value == null || value.isEmpty) {
            return 'Required';
          }
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
