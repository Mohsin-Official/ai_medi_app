import 'package:ai_medi_app/models/conversation.dart';
import 'package:ai_medi_app/models/message.dart';
import 'package:ai_medi_app/services/ai_service.dart';
import 'package:ai_medi_app/services/context_service.dart';
import 'package:ai_medi_app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final Conversation? initialConversation;
  const ChatScreen({super.key, this.initialConversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiService _aiService = AiService();
  final StorageService _storageService = StorageService();
  final Uuid _uuid = Uuid();

  Conversation? _currentCoversation;
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _initializeConversation();
  }

  void _initializeConversation() async {
    if (widget.initialConversation != null) {
      setState(() {
        _currentCoversation = widget.initialConversation;
      });
    } else {
      final welcomeMessage = Message(
        id: _uuid.v4(),
        text:
            "Hello! I'm your Healthcare Assistant. I'm here to help to help you wuth health information, wellness tips, and answer your health-related question. How can i assist you today?",
        isUser: false,
        timestamp: DateTime.now(),
        messageType: 'welcome',
      );

      _currentCoversation = Conversation(
        id: _uuid.v4(),
        title: "New Health Consultation",
        createdAt: DateTime.now(),
        lastUpdate: DateTime.now(),
        messages: [welcomeMessage],
        userContext: {},
      );

      await _storageService.saveConversation(_currentCoversation!);
      await _storageService.setCurrentConversationId(_currentCoversation!.id);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _startNewConversation()async {
    final welcomeMessage = Message(
        id: _uuid.v4(),
        text:
            "Hello! I'm your Healthcare Assistant. I'm here to help to help you wuth health information, wellness tips, and answer your health-related question. How can i assist you today?",
        isUser: false,
        timestamp: DateTime.now(),
        messageType: 'welcome',
      );

      _currentCoversation = Conversation(
        id: _uuid.v4(),
        title: "New Health Consultation",
        createdAt: DateTime.now(),
        lastUpdate: DateTime.now(),
        messages: [welcomeMessage],
        userContext: {},
      );

      await _storageService.saveConversation(_currentCoversation!);
      await _storageService.setCurrentConversationId(_currentCoversation!.id);
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final newContext = ContextService.extractUserContext(text);
    final updatedContext = ContextService.mergeContext(
      _currentCoversation!.userContext,
      newContext,
    );

    final userMessage = Message(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      messageType: _aiService.extractMessageType(text),
    );

    final UpdatedMessages = List<Message>.from(_currentCoversation!.messages)
      ..add(userMessage);

    setState(() {
      _currentCoversation = _currentCoversation!.copyWith(
        messages: UpdatedMessages,
        userContext: updatedContext,
        lastUpdate: DateTime.now(),
      );

      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final response = await _aiService.sendMessage(text, _currentCoversation);

      final aiMessage = Message(
        id: _uuid.v4(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        messageType: 'response',
      );

      final finalMessages = List<Message>.from(_currentCoversation!.messages)
        ..add(aiMessage);

      setState(() {
        _currentCoversation = _currentCoversation!.copyWith(
          messages: finalMessages,
          tilte: _generateConversationTitle(finalMessages),
          lastUpdate: DateTime.now(),
        );
        _isLoading = false;
      });

      await _storageService.saveConversation(_currentCoversation!);
    } catch (e) {
      final errorMessage = Message(
        id: _uuid.v4(),
        text:
            "I apologize, but I'm having issue right now. Please Try again. May be Internet or something other went wrong. Please consult with healthcare proffestional directly for now or Try again.",
        isUser: false,
        timestamp: DateTime.now(),
        messageType: 'error',
      );

      final errorMessages = List<Message>.from(_currentCoversation!.messages)
        ..add(errorMessage);

      setState(() {
        _currentCoversation = _currentCoversation!.copyWith(
          messages: errorMessages,
          lastUpdate: DateTime.now(),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  String _generateConversationTitle(List<Message> messages) {
    if (messages.length < 1) return "New Health Consultation";

    final firstUserMessage = messages.firstWhere(
      (m) => m.isUser,
      orElse: () => messages.first,
    );

    String title = firstUserMessage.text;
    if (title.length > 30) {
      title = title.substring(0, 30) + '...';
    }

    return title;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(microseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showConversations() {
    //   Navigator.push(
    //     context, MaterialPageRoute(
    //       builder: (context)=> ConversationsScreen(
    //   onConversationSelected: (conversation){
    //     setState(() {
    //     _currentCoversation = conversation;
    //     });
    //     Navigator.pop(context);
    //   },
    //   ),
    //   ),
    //   );
  }

  void _clearCurrentChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear Current Chat"),
        content: Text(
          "Are you sure you want to clear the current conversation? This action can not be undone",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (_currentCoversation != null) {
                await _storageService.deleteConversation(
                  _currentCoversation!.id,
                );
              }
              Navigator.pop(context);
              _initializeConversation();
            },
            child: Text("clear", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00BFA6), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.health_and_safety, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Assistant',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Your Personal Healthcare Companion",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF00BFA6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _startNewConversation,
            icon: Icon(Icons.chat_bubble_outline),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Color(0xFF6B7280)),
            onSelected: (value) {
              if (value == 'clear') {
                _clearCurrentChat();
              } else if (value == 'conversations') {
                _showConversations();
              }
            },
            itemBuilder:(context) => [
              PopupMenuItem(
                value: 'conversations',
                child: Row(
                children: [
                  Icon(Icons.history,
                  size: 20,
                  color: Color(0xFF6B7280)),
                  SizedBox(width: 12),
                  Text('View All Chats'),
                ],
              ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                children: [
                  Icon(Icons.delete_outline,
                  size: 20,
                  color: Colors.redAccent),
                  SizedBox(width: 12),
                  Text('Clear Current Chat'),
                ],
              ),
              ),
            ] ,
          ),
        ],
      ),
    );
  }
}
