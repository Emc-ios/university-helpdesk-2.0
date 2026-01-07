import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();
  File? _attachedImage;
  bool _isUploading = false;

  // Input Controllers
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // State Variables
  String? _selectedCategory;
  bool _isLoading = false;
  String? _fileName; // For storing mock attachment name

  // Dropdown Options
  final List<String> _categories = [
    'Enrollment',
    'Scholarship',
    'Grades & Records',
    'Account Issue',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Ticket"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Submit an inquiry to the University Office.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // 1. Category Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) =>
                    val == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 15),

              // 2. Subject Field
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: "Subject",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter a subject' : null,
              ),
              const SizedBox(height: 15),

              // 3. Description Field
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Please describe your issue' : null,
              ),
              const SizedBox(height: 15),

              // // 4. Attachment Button (Mock UI)
              // OutlinedButton.icon(
              //   onPressed: () {
              //     // Logic to pick file (requires file_picker package)
              //     setState(() {
              //       _fileName = "screenshot_error.png"; // Mock file selection
              //     });
              //   },
              //   icon: const Icon(Icons.attach_file),
              //   label: Text(_fileName ?? "Attach File (Optional)"),
              //   style: OutlinedButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(vertical: 15),
              //   ),
              // ),
              // if (_fileName != null)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 5),
              //     child: Text(
              //       "File attached: $_fileName",
              //       style: const TextStyle(fontSize: 12, color: Colors.green),
              //     ),
              //   ),

              // const SizedBox(height: 30),
              OutlinedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _attachedImage = File(pickedFile.path);
                      // We set _fileName just for display if you used it before
                      _fileName = pickedFile.name;
                    });
                  }
                },
                icon: const Icon(Icons.attach_file),
                label: Text(
                  _attachedImage != null
                      ? "Image Selected"
                      : "Attach Image (Optional)",
                ),
              ),
              if (_attachedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Image.file(
                    _attachedImage!,
                    height: 100,
                  ), // Preview the image
                ),

              // 5. Submit Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text("Submit Ticket"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

void _submitTicket() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isUploading = true); // Use _isUploading to show loading

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // A. Upload Image First (if exists)
      String? attachmentUrl;
      if (_attachedImage != null) {
        attachmentUrl = await _dbService.uploadFile(_attachedImage!, 'ticket_attachments');
      }

      // B. Create Ticket with the URL
      await _dbService.createTicket(
        user.uid,
        user.email ?? "Unknown",
        _selectedCategory!,
        _subjectController.text,
        _descController.text,
        attachmentUrl, // Pass the URL here
      );

        if (mounted) {
          // Show Success Dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text("Success"),
              content: const Text(
                "Your ticket has been submitted successfully.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close Dialog
                    Navigator.pop(context); // Go back to Dashboard
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to submit ticket: $e")),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
