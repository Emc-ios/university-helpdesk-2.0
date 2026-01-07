import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting dates
import '../../services/database_service.dart';
import 'ticket_detail_view_screen.dart';

class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  final DatabaseService _dbService = DatabaseService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // All, Open, Resolved
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Tickets"),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "All"),
              Tab(text: "Open/Pending"),
              Tab(text: "Resolved"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTicketList(filterStatus: null), // All
            _buildTicketList(
              filterStatus: "Open",
            ), // Open only (simplified logic)
            _buildTicketList(filterStatus: "Resolved"), // Resolved only
          ],
        ),
      ),
    );
  }

  Widget _buildTicketList({String? filterStatus}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.getUserTickets(userId),
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Error State
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // 3. Empty State
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        // 4. Data Filtering and Sorting Logic
        // (We filter and sort here in Dart rather than creating multiple Firestore indexes for simplicity)
        var docs = snapshot.data!.docs.toList();

        // Sort by createdAt (newest first) - handle null timestamps
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['createdAt'] as Timestamp?;
          final bTime = bData['createdAt'] as Timestamp?;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime); // descending - newest first
        });

        // Filter by status if needed
        if (filterStatus != null) {
          if (filterStatus == "Open") {
            // Group "Open" and "In Progress" together for the tab
            docs = docs.where((doc) {
              final status = (doc.data() as Map)['status'];
              return status == 'Open' || status == 'In Progress';
            }).toList();
          } else {
            docs = docs
                .where((doc) => (doc.data() as Map)['status'] == filterStatus)
                .toList();
          }
        }

        if (docs.isEmpty) return _buildEmptyState();

        // 5. List View
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final date =
                (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(data['status']),
                  child: const Icon(
                    Icons.confirmation_number,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  data['subject'] ?? "No Subject",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "${data['category']} • ${DateFormat('MMM d, yyyy').format(date)}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(data['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data['status'] ?? "Open",
                        style: TextStyle(
                          fontSize: 10,
                          color: _getStatusColor(data['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketDetailViewScreen(
                        ticketId: doc.id,
                        ticketData: data,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("No tickets found", style: TextStyle(color: Colors.grey)),
        ],
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
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
