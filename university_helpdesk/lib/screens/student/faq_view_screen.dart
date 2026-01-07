import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';

class FaqViewScreen extends StatefulWidget {
  const FaqViewScreen({super.key});

  @override
  State<FaqViewScreen> createState() => _FaqViewScreenState();
}

class _FaqViewScreenState extends State<FaqViewScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Frequently Asked Questions"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search FAQs...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          // FAQ List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _dbService.getFAQs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.help_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No FAQs available yet",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                // Filter FAQs based on search query
                var faqs = snapshot.data!.docs;
                if (_searchQuery.isNotEmpty) {
                  faqs = faqs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final question = (data['question'] ?? '')
                        .toString()
                        .toLowerCase();
                    final answer = (data['answer'] ?? '')
                        .toString()
                        .toLowerCase();
                    final keywords =
                        (data['keywords'] as List<dynamic>?)
                            ?.map((e) => e.toString().toLowerCase())
                            .join(' ') ??
                        '';
                    return question.contains(_searchQuery) ||
                        answer.contains(_searchQuery) ||
                        keywords.contains(_searchQuery);
                  }).toList();
                }

                if (faqs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No FAQs match your search",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final doc = faqs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildFaqCard(
                      question: data['question'] ?? 'No question',
                      answer: data['answer'] ?? 'No answer',
                      keywords:
                          (data['keywords'] as List<dynamic>?)
                              ?.cast<String>() ??
                          [],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard({
    required String question,
    required String answer,
    required List<String> keywords,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: Colors.blueAccent),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: keywords.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  children: keywords.take(3).map((keyword) {
                    return Chip(
                      label: Text(
                        keyword,
                        style: const TextStyle(fontSize: 10),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
