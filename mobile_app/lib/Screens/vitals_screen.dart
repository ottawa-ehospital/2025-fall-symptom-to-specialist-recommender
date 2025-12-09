import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/fitbit_service.dart';
import '../services/apple_health_service.dart';

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({Key? key}) : super(key: key);

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  Map<String, dynamic>? fitbitData;
  Map<String, dynamic>? appleData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchVitals();
  }

  Future<void> _fetchVitals() async {
    try {
      final apple = await AppleHealthService.getLatestVitals();
      final fitbit = await FitbitService.getLatestVitals();

      setState(() {
        appleData = apple;
        fitbitData = fitbit;
        loading = false;
      });
    } catch (e) {
      print(" Error fetching vitals: $e");
      setState(() => loading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading vitals: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        title: const Text("Patient Vitals"),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => loading = true);
              _fetchVitals();
            },
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchVitals,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (appleData != null)
                      _buildVitalsCard(
                        title: "Apple Health (Today)",
                        color: Colors.redAccent,
                        avgHR: appleData?["avg_heart_rate"],
                        latestHR: appleData?["heart_rate"],
                        steps: appleData?["steps"],
                        calories: appleData?["calories"],
                        sleep: appleData?["sleep"],
                        updatedAt: appleData?["timestamp"],
                      ),

                    const SizedBox(height: 20),

                    if (fitbitData != null && fitbitData!.isNotEmpty)
                      _buildVitalsCard(
                        title: "Fitbit (Today)",
                        color: Colors.blueAccent,
                        avgHR: fitbitData?["avg_heart_rate"],
                        latestHR: fitbitData?["heart_rate"],
                        steps: fitbitData?["steps"],
                        calories: fitbitData?["calories"],
                        sleep: fitbitData?["sleep"],
                        updatedAt: fitbitData?["timestamp"],
                      ),

                    if ((appleData == null || appleData!.isEmpty) &&
                        (fitbitData == null || fitbitData!.isEmpty))
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          "No vitals data found.\nPlease ensure permissions are enabled.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  // -------------------- CARD UI ------------------------
  Widget _buildVitalsCard({
    required String title,
    required Color color,
    dynamic avgHR,
    dynamic latestHR,
    dynamic steps,
    dynamic calories,
    dynamic sleep,
    dynamic updatedAt,
  }) {
    String formattedTime = "—";

    if (updatedAt != null) {
      try {
        final dt = DateTime.parse(updatedAt.toString());
        formattedTime = DateFormat("hh:mm a").format(dt);
      } catch (_) {}
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                CircleAvatar(backgroundColor: color, radius: 6),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              "Updated at: $formattedTime",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const Divider(height: 32),

            _vitalRow("Average Heart Rate", avgHR != null ? "$avgHR bpm" : "—"),
            _vitalRow("Latest Heart Rate", latestHR != null ? "$latestHR bpm" : "—"),
            _vitalRow("Steps", steps?.toString() ?? "—"),
            _vitalRow("Calories", calories != null ? "$calories kcal" : "—"),
            _vitalRow("Sleep (mins)", sleep?.toString() ?? "—"),
          ],
        ),
      ),
    );
  }

  Widget _vitalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
