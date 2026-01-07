import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  

  // Collection Reference
  final CollectionReference _ticketsRef = FirebaseFirestore.instance.collection(
    'tickets',
  );

  // // Create a New Ticket
  // Future<void> createTicket(
  //   String userId,
  //   String userName,
  //   String category,
  //   String subject,
  //   String description,
  // ) async {
  //   try {
  //     await _ticketsRef.add({
  //       'userId': userId,
  //       'studentName': userName, // Storing name for easier admin view
  //       'category': category,
  //       'subject': subject,
  //       'description': description,
  //       'status': 'Open', // Default status
  //       'createdAt': FieldValue.serverTimestamp(),
  //       'hasAttachment': false, // Phase 4: Handle file URLs
  //     });
  //   } catch (e) {
  //     print("Error creating ticket: $e");
  //     rethrow; // Pass error to UI to handle
  //   }
  // }

  // // Get Tickets for a specific user (For History Screen)
  // // This uses a simple query without orderBy to avoid requiring a composite index
  // // The UI will handle sorting if needed
  // Stream<QuerySnapshot> getUserTickets(String userId) {
  //   if (userId.isEmpty) {
  //     // Return empty query if no user ID
  //     return _ticketsRef.limit(0).snapshots();
  //   }

  //   // Simple query - no orderBy to avoid index requirement
  //   // If you want to use orderBy, you'll need to create a composite index in Firestore
  //   // Collection: tickets, Fields: userId (Ascending), createdAt (Descending)
  //   return _ticketsRef.where('userId', isEqualTo: userId).snapshots();
  // }

  // // Update Ticket Status and Add Admin Note
  // Future<void> updateTicket(
  //   String ticketId,
  //   String newStatus,
  //   String? adminResponse,
  // ) async {
  //   Map<String, dynamic> data = {
  //     'status': newStatus,
  //     'lastUpdated': FieldValue.serverTimestamp(),
  //   };

  //   if (adminResponse != null && adminResponse.isNotEmpty) {
  //     data['adminResponse'] = adminResponse;
  //   }

  //   await _ticketsRef.doc(ticketId).update(data);
  // }

  // // Send a message in a ticket thread
  // Future<void> sendTicketMessage(
  //   String ticketId,
  //   String message,
  //   String senderRole,
  // ) async {
  //   await _ticketsRef.doc(ticketId).collection('messages').add({
  //     'text': message,
  //     'sender': senderRole, // 'Student' or 'Admin'
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });

  //   // Update the main ticket status just to show activity
  //   await _ticketsRef.doc(ticketId).update({
  //     'lastUpdated': FieldValue.serverTimestamp(),
  //   });
  // }

  // // Stream messages for a specific ticket
  // Stream<QuerySnapshot> getTicketMessages(String ticketId) {
  //   return _ticketsRef
  //       .doc(ticketId)
  //       .collection('messages')
  //       .orderBy('timestamp', descending: false) // Oldest first
  //       .snapshots();
  // }

  // // Get all tickets (for admin)
  // Stream<QuerySnapshot> getAllTickets() {
  //   return _ticketsRef.orderBy('createdAt', descending: true).snapshots();
  // }

  // // Get ticket by ID
  // Future<DocumentSnapshot> getTicketById(String ticketId) async {
  //   return await _ticketsRef.doc(ticketId).get();
  // }

  // // Get FAQs
  // Stream<QuerySnapshot> getFAQs() {
  //   return FirebaseFirestore.instance
  //       .collection('faqs')
  //       .orderBy('question')
  //       .snapshots();
  // }

  // // Get all FAQs (for AI context)
  // Future<QuerySnapshot> getAllFAQs() async {
  //   return await FirebaseFirestore.instance.collection('faqs').get();
  // }
  // --- 1. TICKET OPERATIONS ---

  // Create Ticket (Now supports Image URL)
  Future<void> createTicket(String uid, String name, String category,
      String subject, String desc, String? attachmentUrl) async {
    await _db.collection('tickets').add({
      'studentId': uid,
      'studentName': name,
      'category': category,
      'subject': subject,
      'description': desc,
      'attachmentUrl': attachmentUrl, // New Field
      'status': 'Open',
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Get User Tickets
  Stream<QuerySnapshot> getUserTickets(String uid) {
    return _db
        .collection('tickets')
        .where('studentId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // DELETE TICKET (New)
  Future<void> deleteTicket(String ticketId) async {
    await _db.collection('tickets').doc(ticketId).delete();
  }

  // --- 2. FAQ OPERATIONS ---

  // Add FAQ (Now supports Image URL)
  Future<void> addFaq(String question, String answer, List<String> keywords,
      String category, String? imageUrl) async {
    await _db.collection('faqs').add({
      'question': question,
      'answer': answer,
      'keywords': keywords,
      'category': category,
      'imageUrl': imageUrl, // New Field
    });
  }

  // UPDATE FAQ (New)
  Future<void> updateFaq(String docId, Map<String, dynamic> data) async {
    await _db.collection('faqs').doc(docId).update(data);
  }

  // Delete FAQ
  Future<void> deleteFaq(String docId) async {
    await _db.collection('faqs').doc(docId).delete();
  }

  // --- 3. STORAGE OPERATIONS (New) ---

  // Uploads a file and returns the Download URL
  Future<String?> uploadFile(File file, String folder) async {
    try {
      // Create a unique filename: tickets/12345_image.jpg
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = _storage.ref().child('$folder/$fileName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }
}


