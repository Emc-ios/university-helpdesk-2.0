// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../data/faq_data.dart';

// class FaqManagementScreen extends StatefulWidget {
//   const FaqManagementScreen({super.key});

//   @override
//   State<FaqManagementScreen> createState() => _FaqManagementScreenState();
// }

// class _FaqManagementScreenState extends State<FaqManagementScreen> {
//   final CollectionReference _faqsRef = FirebaseFirestore.instance.collection(
//     'faqs',
//   );
//   final TextEditingController _questionController = TextEditingController();
//   final TextEditingController _answerController = TextEditingController();
//   final TextEditingController _keywordsController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Manage FAQs"),
//         backgroundColor: Colors.indigo,
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           // 1. List of Existing FAQs
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _faqsRef.snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData)
//                   return const Center(child: CircularProgressIndicator());

//                 final docs = snapshot.data!.docs;

//                 return ListView.builder(
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     final data = docs[index].data() as Map<String, dynamic>;
//                     return Card(
//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 5,
//                       ),
//                       child: ListTile(
//                         title: Text(
//                           data['question'],
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Text(
//                           data['answer'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () => _deleteFaq(docs[index].id),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // 2. Action Buttons
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // Import Default FAQs Button
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.cloud_download),
//                   label: const Text("Import Default FAQs"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(double.infinity, 50),
//                   ),
//                   onPressed: _importDefaultFaqs,
//                 ),
//                 const SizedBox(height: 10),
//                 // Add New FAQ Button
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.add),
//                   label: const Text("Add New FAQ"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.indigo,
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(double.infinity, 50),
//                   ),
//                   onPressed: _showAddFaqDialog,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Dialog to Add FAQ
//   void _showAddFaqDialog() {
//     _questionController.clear();
//     _answerController.clear();
//     _keywordsController.clear();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Add FAQ"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _questionController,
//               decoration: const InputDecoration(labelText: "Question"),
//             ),
//             TextField(
//               controller: _answerController,
//               decoration: const InputDecoration(labelText: "Answer"),
//               maxLines: 3,
//             ),
//             TextField(
//               controller: _keywordsController,
//               decoration: const InputDecoration(
//                 labelText: "Keywords (comma separated)",
//               ),
//               //hintText: "enroll, admission, register",
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (_questionController.text.isNotEmpty &&
//                   _answerController.text.isNotEmpty) {
//                 // Parse keywords into a list
//                 List<String> keywords = _keywordsController.text
//                     .toLowerCase()
//                     .split(',')
//                     .map((e) => e.trim())
//                     .toList();

//                 await _faqsRef.add({
//                   'question': _questionController.text,
//                   'answer': _answerController.text,
//                   'keywords': keywords,
//                 });
//                 if (mounted) Navigator.pop(context);
//               }
//             },
//             child: const Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _deleteFaq(String id) {
//     _faqsRef.doc(id).delete();
//   }

//   // Import default FAQs from FAQ data
//   Future<void> _importDefaultFaqs() async {
//     // Show confirmation dialog
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Import Default FAQs"),
//         content: const Text(
//           "This will add all default FAQs to the database. "
//           "Existing FAQs will not be duplicated. Continue?",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Import"),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     // Show loading indicator
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );

//     try {
//       // Get existing FAQs to avoid duplicates
//       final existingFaqs = await _faqsRef.get();
//       final existingQuestions = existingFaqs.docs
//           .map((doc) => (doc.data() as Map)['question'] as String)
//           .toSet();

//       // Get default FAQs
//       final defaultFaqs = FaqData.getDefaultFaqs();
//       int addedCount = 0;
//       int skippedCount = 0;

//       // Add each FAQ if it doesn't already exist
//       for (final faq in defaultFaqs) {
//         final question = faq['question'] as String;
//         if (existingQuestions.contains(question)) {
//           skippedCount++;
//           continue;
//         }

//         await _faqsRef.add({
//           'question': faq['question'],
//           'answer': faq['answer'],
//           'keywords': faq['keywords'],
//           'category': faq['category'],
//         });
//         addedCount++;
//       }

//       // Close loading dialog
//       if (mounted) Navigator.pop(context);

//       // Show result
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "Import complete! Added: $addedCount, Skipped: $skippedCount",
//             ),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     } catch (e) {
//       // Close loading dialog
//       if (mounted) Navigator.pop(context);

//       // Show error
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error importing FAQs: $e"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/database_service.dart';

class FaqManagementScreen extends StatefulWidget {
  const FaqManagementScreen({super.key});

  @override
  State<FaqManagementScreen> createState() => _FaqManagementScreenState();
}

class _FaqManagementScreenState extends State<FaqManagementScreen> {
  final DatabaseService _dbService = DatabaseService();
  final CollectionReference _faqsRef =
      FirebaseFirestore.instance.collection('faqs');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage FAQs")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _faqsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No FAQs yet."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(data['question'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['answer'], maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (data['imageUrl'] != null)
                        const Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Row(children: [
                            Icon(Icons.image, size: 16, color: Colors.blue),
                            SizedBox(width: 5),
                            Text("Has Image", style: TextStyle(color: Colors.blue, fontSize: 12))
                          ]),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // EDIT BUTTON
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFaqDialog(docId: doc.id, existingData: data),
                      ),
                      // DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _dbService.deleteFaq(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFaqDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Unified Dialog for ADD and EDIT
  void _showFaqDialog({String? docId, Map<String, dynamic>? existingData}) {
    final _questionController = TextEditingController(text: existingData?['question'] ?? '');
    final _answerController = TextEditingController(text: existingData?['answer'] ?? '');
    final _keywordsController = TextEditingController(
      text: existingData != null ? (existingData['keywords'] as List).join(', ') : ''
    );
    
    File? _selectedImage;
    String? _existingImageUrl = existingData?['imageUrl'];
    bool _isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(docId == null ? "Add FAQ" : "Edit FAQ"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _questionController, decoration: const InputDecoration(labelText: "Question")),
                  TextField(controller: _answerController, decoration: const InputDecoration(labelText: "Answer"), maxLines: 3),
                  TextField(controller: _keywordsController, decoration: const InputDecoration(labelText: "Keywords (comma separated)")),
                  const SizedBox(height: 10),
                  
                  // IMAGE PICKER UI
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo),
                        label: const Text("Attach Image"),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() => _selectedImage = File(pickedFile.path));
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      if (_selectedImage != null)
                        const Text("Image Selected", style: TextStyle(color: Colors.green))
                      else if (_existingImageUrl != null)
                        const Text("Has Existing Image", style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  if (_isUploading) const LinearProgressIndicator(),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: _isUploading ? null : () async {
                  if (_questionController.text.isEmpty || _answerController.text.isEmpty) return;
                  
                  setState(() => _isUploading = true);

                  // 1. Upload Image if selected
                  String? imageUrl = _existingImageUrl;
                  if (_selectedImage != null) {
                    imageUrl = await _dbService.uploadFile(_selectedImage!, 'faq_images');
                  }

                  // 2. Prepare Data
                  final data = {
                    'question': _questionController.text,
                    'answer': _answerController.text,
                    'keywords': _keywordsController.text.split(',').map((e) => e.trim()).toList(),
                    'imageUrl': imageUrl,
                    'category': 'General', // Can add dropdown for this later
                  };

                  // 3. Save to Firestore
                  if (docId == null) {
                    await _dbService.addFaq(data['question'] as String, data['answer'] as String, data['keywords'] as List<String>, 'General', imageUrl);
                  } else {
                    await _dbService.updateFaq(docId, data);
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(docId == null ? "Add" : "Save Changes"),
              ),
            ],
          );
        },
      ),
    );
  }
}