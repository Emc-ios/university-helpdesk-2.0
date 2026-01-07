import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Ensure you have intl package, or remove formatting
import '../../services/auth_service.dart';
import 'ticket_detail_screen.dart';
import 'analytics_dashboard.dart';
import 'faq_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _auth = AuthService();
  final CollectionReference _ticketsRef = FirebaseFirestore.instance.collection(
    'tickets',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // 1. FAQ Management Button (New)
          IconButton(
            icon: const Icon(
              Icons.library_books,
            ), // Icon for "Library/Knowledge"
            tooltip: "Manage FAQs",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FaqManagementScreen(),
                ),
              );
            },
          ),

          // 2. Analytics Button (Existing)
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: "Analytics",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsDashboard(),
                ),
              );
            },
          ),

          // 3. Logout Button (Existing)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ticketsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          // Inside StreamBuilder builder:
          if (snapshot.hasError) {
            // This will print the exact error on your phone screen
            return Center(
              child: Text(
                "Error loading tickets:\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tickets found."));
          }

          final allTickets = snapshot.data!.docs;

          // Calculate Summary Stats
          final int total = allTickets.length;
          final int open = allTickets
              .where((doc) => (doc.data() as Map)['status'] == 'Open')
              .length;
          final int inProgress = allTickets
              .where((doc) => (doc.data() as Map)['status'] == 'In Progress')
              .length;

          return Column(
            children: [
              // 1. Summary Cards Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildSummaryCard(
                      "Total",
                      total.toString(),
                      Colors.blueGrey,
                    ),
                    const SizedBox(width: 10),
                    _buildSummaryCard(
                      "Open",
                      open.toString(),
                      Colors.redAccent,
                    ),
                    const SizedBox(width: 10),
                    _buildSummaryCard(
                      "In Progress",
                      inProgress.toString(),
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 2. Ticket List Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: Colors.grey[200],
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Subject",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Student",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Status",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Ticket List
              Expanded(
                child: ListView.builder(
                  itemCount: allTickets.length,
                  itemBuilder: (context, index) {
                    final doc = allTickets[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final date =
                        (data['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now();

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketDetailScreen(
                              ticketId: doc.id, // Pass the Document ID
                              data: data, // Pass the Document Data
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Subject & Category
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['subject'] ?? "No Subject",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${data['category']} • ${DateFormat('MM/dd HH:mm').format(date)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Student Name (or Email)
                            Expanded(
                              flex: 1,
                              child: Text(
                                data['studentName'] ?? "Unknown",
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Status Badge
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      data['status'],
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    data['status'] ?? "Open",
                                    style: TextStyle(
                                      color: _getStatusColor(data['status']),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper: Summary Card
  Widget _buildSummaryCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Open':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
