import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  bool _isTyping = false;

  // 1. Initialize Gemini
  // IMPORTANT: Get your API key from https://aistudio.google.com/app/apikey
  // Make sure the API key has access to Gemini models
  // API keys from Google AI Studio start with "AIza..."
  // If your key doesn't start with "AIza", you may have copied the wrong value
  GenerativeModel? _model;
  final String _apiKey = 'AIzaSyD5wH010InhXFEQTgjdkZQzl9gDC86R6xQ';

  // NOTE: If you're getting errors, check:
  // 1. API key is valid and active at https://aistudio.google.com/app/apikey
  // 2. API key has Gemini API enabled in Google Cloud Console
  // 3. Your internet connection is working
  // 4. Check the console logs for detailed error messages
  // 5. Model name: Using 'gemini-pro' (standard stable model)

  // Store FAQs and context here to feed to the AI
  String _universityKnowledge = "";
  final List<Content> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    // Initialize with the first model name
    _initializeModel();
    _loadFaqContext();

    // Add an initial welcome message
    _messages.add({
      "isUser": false,
      "text":
          "Hello! I'm your AI university assistant. I can help you with:\n• General questions about the university\n• Enrollment and registration\n• Scholarships and financial aid\n• Academic records\n• Account issues\n\nIf I can't answer your question, I'll guide you to create a support ticket.",
      "time": DateTime.now(),
    });
  }

  // Initialize the model
  // Using gemini-1.5-flash-latest which is the current recommended model
  // If this doesn't work, check available models at: https://ai.google.dev/models/gemini
  void _initializeModel() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview', // Latest stable flash model
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
    print("Initialized model: gemini-1.5-flash-latest");
  }

  // 2. Load all FAQs from Firestore to teach the AI with enhanced context
  Future<void> _loadFaqContext() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('faqs')
          .get();
      final buffer = StringBuffer();

      // Enhanced system prompt with better instructions
      buffer.writeln(
        "You are a friendly and professional AI assistant for a university helpdesk system. "
        "Your role is to help students with their questions using the knowledge base below. "
        "Be concise, helpful, and empathetic. If a question cannot be answered from the provided "
        "information, politely suggest creating a support ticket for personalized assistance.\n",
      );

      buffer.writeln("=== UNIVERSITY KNOWLEDGE BASE ===\n");

      if (snapshot.docs.isEmpty) {
        buffer.writeln(
          "No FAQs available yet. Please ask general questions or create a ticket for specific help.",
        );
      } else {
        // Group by category for better organization
        final Map<String, List<Map<String, dynamic>>> categorizedFaqs = {};

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final category = (data['category'] as String?) ?? 'General';
          if (!categorizedFaqs.containsKey(category)) {
            categorizedFaqs[category] = [];
          }
          categorizedFaqs[category]!.add(data);
        }

        // Write FAQs grouped by category
        categorizedFaqs.forEach((category, faqs) {
          buffer.writeln("[$category]");
          for (var faq in faqs) {
            buffer.writeln("Q: ${faq['question']}");
            buffer.writeln("A: ${faq['answer']}");
            if (faq['keywords'] != null &&
                (faq['keywords'] as List).isNotEmpty) {
              buffer.writeln(
                "Keywords: ${(faq['keywords'] as List).join(', ')}",
              );
            }
            buffer.writeln("---\n");
          }
          buffer.writeln("\n");
        });
      }

      buffer.writeln(
        "\n=== INSTRUCTIONS ===\n"
        "1. Answer questions based on the knowledge base above.\n"
        "2. If the answer isn't in the knowledge base, suggest creating a ticket.\n"
        "3. Be friendly, professional, and concise.\n"
        "4. For urgent matters, always recommend creating a ticket.\n"
        "5. Use the keywords to better understand related questions.\n",
      );

      _universityKnowledge = buffer.toString();
      print("AI Context Loaded: ${_universityKnowledge.length} characters");
    } catch (e) {
      print("Error loading FAQs: $e");
      _universityKnowledge =
          "You are a helpful university assistant. Answer questions to the best of your ability.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assistant"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(
                  text: msg['text'],
                  isUser: msg['isUser'],
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "AI is thinking...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble({required String text, required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = text.trim();

    // 1. Show User Message
    setState(() {
      _messages.add({
        "isUser": true,
        "text": userMessage,
        "time": DateTime.now(),
      });
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // 2. Build conversation with context
    final List<Content> contents = [];

    try {
      // Check if context is loaded
      if (_universityKnowledge.isEmpty) {
        print("Warning: University knowledge not loaded yet, loading now...");
        await _loadFaqContext();
      }

      // Build the prompt with context and user message
      // Combine system context with user message for better results
      String fullPrompt;
      if (_universityKnowledge.isNotEmpty) {
        // Truncate context if too long (Gemini has token limits)
        final maxContextLength = 8000; // Leave room for conversation
        final truncatedContext = _universityKnowledge.length > maxContextLength
            ? _universityKnowledge.substring(0, maxContextLength) +
                  "...\n[Context truncated]"
            : _universityKnowledge;

        fullPrompt =
            "$truncatedContext\n\nStudent Question: $userMessage\n\nPlease provide a helpful answer based on the knowledge base above. If the answer isn't in the knowledge base, suggest creating a support ticket.";
      } else {
        fullPrompt =
            "You are a helpful university assistant. Answer the following question: $userMessage";
      }

      // Add conversation history for context (last 5 exchanges)
      final recentHistory = _conversationHistory.length > 10
          ? _conversationHistory.sublist(_conversationHistory.length - 10)
          : _conversationHistory;

      // Build contents with history + current prompt
      contents.addAll(recentHistory);
      contents.add(Content.text(fullPrompt));

      // Add to conversation history
      _conversationHistory.add(Content.text(userMessage));

      // Limit history size to prevent memory issues
      if (_conversationHistory.length > 20) {
        _conversationHistory.removeRange(0, _conversationHistory.length - 20);
      }

      print("Sending request to Gemini with ${contents.length} content items");

      // Ensure model is initialized
      if (_model == null) {
        throw Exception(
          "Model not initialized. Please check your API key and model availability.",
        );
      }

      // 3. Get Response from Gemini
      final response = await _model!.generateContent(contents);
      final botReply =
          response.text ??
          "I apologize, but I'm having trouble processing your request. Please try again or create a support ticket.";

      // Add bot response to history for context in next messages
      _conversationHistory.add(Content.text(botReply));

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            "isUser": false,
            "text": botReply,
            "time": DateTime.now(),
          });
        });
      }
    } catch (e, stackTrace) {
      // Better error handling with detailed logging
      print("=== GEMINI API ERROR ===");
      print("Error: $e");
      print("Stack Trace: $stackTrace");
      print("API Key: ${_apiKey.substring(0, 10)}...");
      print("Context Length: ${_universityKnowledge.length}");
      print("Contents Count: ${contents.length}");
      print("User Message: $userMessage");
      print("========================");

      String errorMessage;

      // Check for specific error types
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('api_key') ||
          errorString.contains('invalid api key') ||
          errorString.contains('authentication') ||
          errorString.contains('unauthorized')) {
        errorMessage =
            "API configuration error. Please check the API key settings.";
      } else if ((errorString.contains('model') &&
              (errorString.contains('not found') ||
                  errorString.contains('not available') ||
                  errorString.contains('404'))) ||
          errorString.contains('models/gemini')) {
        errorMessage =
            "Model 'gemini-1.5-flash-latest' not found. "
            "Try updating the model name in chatbot_screen.dart line 59 to: "
            "'gemini-1.5-pro-latest', 'gemini-1.5-flash', or 'gemini-pro'. "
            "Check available models at: https://ai.google.dev/models/gemini";
      } else if (errorString.contains('quota') ||
          errorString.contains('limit') ||
          errorString.contains('rate limit')) {
        errorMessage =
            "Service temporarily unavailable due to rate limits. Please try again in a few moments.";
      } else if (errorString.contains('network') ||
          errorString.contains('connection') ||
          errorString.contains('timeout')) {
        errorMessage =
            "Network connection issue. Please check your internet connection and try again.";
      } else if (errorString.contains('safety') ||
          errorString.contains('blocked') ||
          errorString.contains('content policy')) {
        errorMessage =
            "Your message was blocked by content safety filters. Please rephrase your question.";
      } else if (errorString.contains('invalid argument') ||
          errorString.contains('bad request')) {
        errorMessage =
            "Invalid request format. Please try rephrasing your question.";
      } else {
        // For debugging: show actual error in development
        errorMessage =
            "I'm having trouble processing your request. "
            "Error: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}. "
            "Please try again or create a support ticket.";
      }

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            "isUser": false,
            "text": errorMessage,
            "time": DateTime.now(),
          });
        });
      }
    }
    _scrollToBottom();
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
}
