import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  final CollectionReference _ticketsRef =
      FirebaseFirestore.instance.collection('tickets');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics & Reports"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ticketsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          }

          final tickets = snapshot.data!.docs;
          if (tickets.isEmpty) return const Center(child: Text("No data available"));

          // --- 1. PROCESS DATA ---
          int total = tickets.length;
          int resolved = 0;
          int open = 0;
          Map<String, int> categories = {};

          for (var doc in tickets) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'];
            final category = data['category'] ?? 'Other';

            // Count Status
            if (status == 'Resolved') resolved++;
            else open++; // Grouping Open and In Progress together

            // Count Categories
            if (categories.containsKey(category)) {
              categories[category] = categories[category]! + 1;
            } else {
              categories[category] = 1;
            }
          }

          // Calculate Resolution Rate
          double resolutionRate = total > 0 ? (resolved / total) * 100 : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 2. KPI CARDS ---
                Row(
                  children: [
                    _buildKpiCard("Total Inquiries", total.toString(), Colors.blue),
                    const SizedBox(width: 10),
                    _buildKpiCard("Resolution Rate", "${resolutionRate.toStringAsFixed(1)}%", Colors.green),
                  ],
                ),
                const SizedBox(height: 30),

                // --- 3. PIE CHART (Status) ---
                const Text("Ticket Status Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: resolved.toDouble(),
                          title: '$resolved',
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.orange,
                          value: open.toDouble(),
                          title: '$open',
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 12),
                    Text(" Resolved  "),
                    Icon(Icons.circle, color: Colors.orange, size: 12),
                    Text(" Pending"),
                  ],
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),

                // --- 4. LIST SUMMARY (Categories) ---
                // (Using a simple list instead of BarChart for simplicity in MVP)
                const Text("Inquiries by Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...categories.entries.map((entry) {
                  double percentage = (entry.value / total);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text("${entry.value} (${(percentage * 100).toStringAsFixed(0)}%)"),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey[200],
                          color: Colors.indigo,
                          minHeight: 8,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}