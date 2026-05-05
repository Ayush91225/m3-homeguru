import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/mascot/chill_sprite.dart';
import '../../../widgets/shared/guruai/chat_message.dart';
import '../../../widgets/shared/guruai/quick_actions.dart';


class GuruAIScreen extends StatefulWidget {
  const GuruAIScreen({super.key});

  @override
  State<GuruAIScreen> createState() => _GuruAIScreenState();
}

class _GuruAIScreenState extends State<GuruAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final List<ChatHistory> _chatHistory = [];
  final Map<String, List<ChatMessage>> _savedChats = {};
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentChatId = '';

  @override
  void initState() {
    super.initState();
    _currentChatId = DateTime.now().millisecondsSinceEpoch.toString();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('chat_history') ?? [];
    final chatsJson = prefs.getString('saved_chats') ?? '{}';
    
    setState(() {
      _chatHistory.clear();
      _chatHistory.addAll(
        historyJson.map((json) => ChatHistory.fromJson(jsonDecode(json))).toList(),
      );
      
      _savedChats.clear();
      final Map<String, dynamic> chatsMap = jsonDecode(chatsJson);
      chatsMap.forEach((key, value) {
        _savedChats[key] = (value as List)
            .map((msg) => ChatMessage(
                  text: msg['text'],
                  isUser: msg['isUser'],
                ))
            .toList();
      });
    });
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _chatHistory.map((chat) => jsonEncode(chat.toJson())).toList();
    await prefs.setStringList('chat_history', historyJson);
    
    // Save all chat messages
    final chatsMap = <String, dynamic>{};
    _savedChats.forEach((key, value) {
      chatsMap[key] = value
          .map((msg) => {'text': msg.text, 'isUser': msg.isUser})
          .toList();
    });
    await prefs.setString('saved_chats', jsonEncode(chatsMap));
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Save to chat history if first message
    if (_messages.length == 1) {
      setState(() {
        _chatHistory.insert(
          0,
          ChatHistory(
            id: _currentChatId,
            title: text.length > 40 ? '${text.substring(0, 40)}...' : text,
            timestamp: DateTime.now(),
          ),
        );
      });
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'I\'m Guru AI, your intelligent learning companion. I can help you understand concepts, solve problems, practice languages, and much more. What would you like to learn today?',
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
        
        // Save current chat messages
        _savedChats[_currentChatId] = List.from(_messages);
        _saveChatHistory();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _loadChat(String chatId) {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    
    setState(() {
      _currentChatId = chatId;
      _messages.clear();
      if (_savedChats.containsKey(chatId)) {
        _messages.addAll(_savedChats[chatId]!);
      }
      _isLoading = false;
    });
    
    _scrollToBottom();
  }

  void _newChat() {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    setState(() {
      _messages.clear();
      _isLoading = false;
      _currentChatId = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _messages.add(ChatMessage(
            text: '',
            isUser: true,
            imagePath: image.path,
          ));
          _isLoading = true;
        });
        _scrollToBottom();

        if (_messages.length == 1) {
          setState(() {
            _chatHistory.insert(
              0,
              ChatHistory(
                id: _currentChatId,
                title: 'Image: ${image.name}',
                timestamp: DateTime.now(),
              ),
            );
          });
          _saveChatHistory();
        }

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _messages.add(ChatMessage(
                text: 'I can see your image! How can I help you with it?',
                isUser: false,
              ));
              _isLoading = false;
            });
            _scrollToBottom();
            
            // Save current chat messages
            _savedChats[_currentChatId] = List.from(_messages);
            _saveChatHistory();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ChillSprite(size: 28),
            const SizedBox(width: 10),
            const Text('Guru AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: _newChat,
              tooltip: 'New chat',
            ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            tooltip: 'Chat history',
          ),
        ],
      ),
      endDrawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildChatList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 64, 16, 20),
            decoration: BoxDecoration(color: cs.surfaceContainerLow),
            child: Row(
              children: [
                Text('Chats', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: _newChat,
                  tooltip: 'New chat',
                  style: IconButton.styleFrom(
                    backgroundColor: cs.primaryContainer,
                    foregroundColor: cs.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _chatHistory.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No chats yet',
                            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: _chatHistory.length,
                    itemBuilder: (context, index) {
                      final chat = _chatHistory[index];
                      return _ChatHistoryItem(
                        chat: chat,
                        isActive: chat.id == _currentChatId,
                        onTap: () => _loadChat(chat.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return ChatMessageWidget(
            message: ChatMessage(text: '', isUser: false),
            isLoading: true,
          );
        }
        return ChatMessageWidget(message: _messages[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getGreeting(),
              style: tt.displaySmall?.copyWith(
                fontWeight: FontWeight.w300,
                fontSize: 40,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How can I help you today?',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildInputArea() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_messages.isEmpty)
          QuickActions(onActionTap: _sendMessage),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(
              top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  tooltip: 'Send image',
                  onPressed: _pickImage,
                  color: cs.onSurfaceVariant,
                ),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Message Guru AI',
                        hintStyle: TextStyle(color: cs.onSurfaceVariant),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(fontSize: 15, color: cs.onSurface),
                      onSubmitted: (_) => _sendMessage(_controller.text),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [cs.primary, cs.tertiary]
                          : [
                              Color.lerp(cs.primary, Colors.white, 0.2)!,
                              Color.lerp(cs.tertiary, Colors.white, 0.2)!,
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _sendMessage(_controller.text),
                    icon: Icon(Icons.send_rounded, color: cs.onPrimary),
                    iconSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChatHistory {
  final String id;
  final String title;
  final DateTime timestamp;

  ChatHistory({required this.id, required this.title, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatHistory.fromJson(Map<String, dynamic> json) => ChatHistory(
    id: json['id'],
    title: json['title'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class _ChatHistoryItem extends StatelessWidget {
  const _ChatHistoryItem({
    required this.chat,
    required this.isActive,
    required this.onTap,
  });

  final ChatHistory chat;
  final bool isActive;
  final VoidCallback onTap;

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isActive ? cs.primaryContainer.withValues(alpha: 0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: isActive
                ? BoxDecoration(
                    border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  )
                : null,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.title,
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimestamp(chat.timestamp),
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  iconSize: 18,
                  onPressed: () {},
                  color: cs.onSurfaceVariant,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
