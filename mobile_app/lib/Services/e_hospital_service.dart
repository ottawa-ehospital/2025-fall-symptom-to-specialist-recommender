import 'dart:convert';
import 'package:http/http.dart' as http;

class EHospitalService {
  static const String baseUrl =
      "https://aetab8pjmb.us-east-1.awsapprunner.com";

  // ----------------------------------------------------------
  // SEND VITALS TO wearable_vitals TABLE
  // ----------------------------------------------------------
  static Future<void> sendWearableVitals({
    required String patientId,
    required int heartRate,
    required int steps,
    required int calories,
    required int sleep,
  }) async {
    final url = Uri.parse('$baseUrl/table/wearable_vitals');

    final data = {
      "patient_id": patientId,
      "heart_rate": heartRate,
      "steps": steps,
      "calories": calories,
      "sleep": sleep,
      "timestamp": DateTime.now().toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print(" Wearable vitals saved to backend!");
    } else {
      print(" Failed to save wearable vitals → ${response.statusCode}");
      print(response.body);
    }
  }
}
