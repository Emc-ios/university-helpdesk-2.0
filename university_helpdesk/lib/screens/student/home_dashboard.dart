import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import 'create_ticket_screen.dart';
import 'chatbot_screen.dart';
import 'ticket_history_screen.dart';
import 'faq_view_screen.dart';
import 'ticket_detail_view_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final AuthService _auth = AuthService();
  final DatabaseService _dbService = DatabaseService();
  int _selectedIndex = 0; // For Bottom Navigation Bar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background for contrast
      // 1. Top AppBar
      appBar: AppBar(
        title: const Text("UniHelp Desk"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to Profile Screen (Phase 4)
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),

      // 2. Main Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Text
            const Text(
              "Welcome, Student!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "How can we help you today?",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 3. Quick Action Cards (Grid)
            GridView.count(
              shrinkWrap: true, // Vital for nesting GridView inside ScrollView
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, // 2 cards per row
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  title: "Chatbot Assistance",
                  icon: Icons.chat_bubble_outline,
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to Chatbot Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatbotScreen(),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  title: "FAQs",
                  icon: Icons.question_answer_outlined,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FaqViewScreen(),
                      ),
                    );
                  },
                ),
                // _buildActionCard(
                //   title: "Create Ticket",
                //   icon: Icons.add_circle_outline,
                //   color: Colors.green,
                //   onTap: () {
                //     // Navigate to Create Ticket Screen
                //     print("Go to Create Ticket");
                //   },
                // ),
                _buildActionCard(
                  title: "Create Ticket",
                  icon: Icons.add_circle_outline,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateTicketScreen(),
                      ),
                    );
                  },
                ),
                // _buildActionCard(
                //   title: "Ticket Status",
                //   icon: Icons.history,
                //   color: Colors.purple,
                //   notificationCount: 2, // Example badge
                //   onTap: () {
                //     // Navigate to Ticket History
                //     print("Go to History");
                //   },
                // ),
                _buildActionCard(
                  title: "Ticket Status",
                  icon: Icons.history,
                  color: Colors.purple,
                  notificationCount:
                      0, // You can link this to real counts later
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TicketHistoryScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 4. Recent Activity Header
            const Text(
              "Recent Tickets",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 5. Recent Activity List (Real Data from Firestore)
            StreamBuilder<QuerySnapshot>(
              stream: _dbService.getUserTickets(
                FirebaseAuth.instance.currentUser?.uid ?? '',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 10),
                          Text(
                            "No tickets yet",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Create your first ticket to get started",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Sort by createdAt (newest first) and show only the 3 most recent tickets
                final allTickets = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['createdAt'] as Timestamp?;
                    final bTime = bData['createdAt'] as Timestamp?;

                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;

                    return bTime.compareTo(aTime); // descending - newest first
                  });

                final recentTickets = allTickets.take(3).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTickets.length,
                  itemBuilder: (context, index) {
                    final doc = recentTickets[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final date =
                        (data['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now();

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(data['status']),
                          child: const Icon(
                            Icons.assignment,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          data['subject'] ?? "No Subject",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${data['status']} • ${DateFormat('MMM d, yyyy').format(date)}",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
            ),
          ],
        ),
      ),

      // 6. Bottom Navigation Bar
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.blueAccent,
      //   unselectedItemColor: Colors.grey,
      //   onTap: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //       // Handle navigation logic here later
      //     });
      //   },
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      //   ],
      // ),
    );
  }

  // Helper Widget for Action Cards
  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    int notificationCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 32, color: color),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Notification Badge Logic
            if (notificationCount > 0)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    notificationCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper to color code statuses
  Color _getStatusColor(String status) {
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
