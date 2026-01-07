import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  final Map<String, dynamic> data;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    required this.data,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _responseController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String _currentStatus;
  bool _isLoading = false;
  bool _isSendingMessage = false;

  final List<String> _statusOptions = ['Open', 'In Progress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    // Initialize with existing data
    _currentStatus = widget.data['status'] ?? 'Open';
    if (widget.data['adminResponse'] != null) {
      _responseController.text = widget.data['adminResponse'];
    }
  }

  @override
  void dispose() {
    _responseController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date =
        (widget.data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Manage Ticket"),
      //   backgroundColor: Colors.indigo,
      //   foregroundColor: Colors.white,
      // ),
      // Inside build() method
appBar: AppBar(
  title: const Text("Ticket Details"),
  actions: [
    // Only allow delete if status is NOT "Resolved" (optional logic)
    if (widget.ticketData['status'] != 'Resolved')
      IconButton(
        icon: const Icon(Icons.delete),
        tooltip: "Delete Ticket",
        onPressed: () async {
          // Confirm Dialog
          bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Delete Ticket?"),
              content: const Text("Are you sure you want to remove this ticket? This cannot be undone."),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text("Delete")),
              ],
            ),
          ) ?? false;

          if (confirm) {
             // Call the Delete Service
             await DatabaseService().deleteTicket(widget.ticketId);
             if (context.mounted) {
               Navigator.pop(context); // Go back to list
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket deleted.")));
             }
          }
        },
      ),
  ],
),
      body: Column(
        children: [
          // Ticket Info Section (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Ticket ID: ...${widget.ticketId.substring(widget.ticketId.length - 6)}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy h:mm a').format(date),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 2. Main Ticket Details
                  Text(
                    widget.data['subject'] ?? "No Subject",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Chip(
                    label: Text(widget.data['category']),
                    backgroundColor: Colors.blue.shade50,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Student Description:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      widget.data['description'] ?? "No description provided.",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 3. Admin Action Section
                  const Text(
                    "Admin Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: _currentStatus,
                    decoration: const InputDecoration(
                      labelText: "Update Status",
                      border: OutlineInputBorder(),
                    ),
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _currentStatus = val);
                    },
                  ),
                  const SizedBox(height: 15),

                  // Response Field
                  TextField(
                    controller: _responseController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Response to Student",
                      hintText: "Type your reply here...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 4. Messages Section
                  const Text(
                    "Conversation",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _dbService.getTicketMessages(widget.ticketId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }

                        final messages = snapshot.data?.docs ?? [];

                        if (messages.isEmpty) {
                          return const Center(
                            child: Text(
                              "No messages yet",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg =
                                messages[index].data() as Map<String, dynamic>;
                            final isAdmin = msg['sender'] == 'Admin';
                            final timestamp =
                                (msg['timestamp'] as Timestamp?)?.toDate() ??
                                DateTime.now();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Align(
                                alignment: isAdmin
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAdmin
                                        ? Colors.indigo
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg['text'] ?? '',
                                        style: TextStyle(
                                          color: isAdmin
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat('h:mm a').format(timestamp),
                                        style: TextStyle(
                                          color: isAdmin
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Quick Message Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "Quick message...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _sendQuickMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: _isSendingMessage
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.indigo),
                        onPressed: _isSendingMessage ? null : _sendQuickMessage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 5. Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _updateTicket,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Save Changes"),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendQuickMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSendingMessage = true);

    try {
      await _dbService.sendTicketMessage(widget.ticketId, message, 'Admin');
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error sending message: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingMessage = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _updateTicket() async {
    if (_responseController.text.trim().isEmpty &&
        _currentStatus == widget.data['status']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please make a change before saving")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _dbService.updateTicket(
        widget.ticketId,
        _currentStatus,
        _responseController.text.trim().isNotEmpty
            ? _responseController.text
            : null,
      );

      // If there's a response, also send it as a message
      if (_responseController.text.trim().isNotEmpty) {
        await _dbService.sendTicketMessage(
          widget.ticketId,
          _responseController.text,
          'Admin',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ticket updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to Dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating ticket: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
