import '../utils/gemini_ai.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/model/message.dart';
import 'firstMenu.dart';
import 'secondMenu_screen.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;

  const ChatScreen({Key? key, this.chatId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userMessage = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  late DocumentReference _currentChatDocRef;
  bool _isChatSessionStarted = false;

  @override
  void initState() {
    super.initState();
    if (widget.chatId != null) {
      _loadChatMessages(widget.chatId!);
      _isChatSessionStarted = true;
      _currentChatDocRef = FirebaseFirestore.instance.collection('chat_history').doc(widget.chatId);
    }
  }

  Future<void> _loadChatMessages(String chatId) async {
    try {
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('chat_history')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      final messages = messagesSnapshot.docs.map((doc) {
        final data = doc.data();
        final isUser = data['sender'] == 'user';
        return Message(
          isUser: isUser,
          message: data['message'],
          date: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();

      setState(() {
        _messages.addAll(messages);
      });

      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  Future<void> _startNewChatSession() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user is authenticated.");
        return;
      }

      final chatHistoryCollection = FirebaseFirestore.instance.collection('chat_history');
      _currentChatDocRef = await chatHistoryCollection.add({
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isChatSessionStarted = true;
      });
    } catch (e) {
      print("Error starting new chat session: $e");
    }
  }

  Future<void> sendMessage() async {
    final message = _userMessage.text;
    _userMessage.clear();

    if (!_isChatSessionStarted) {
      await _startNewChatSession();
    }

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
      _messages.add(Message(isUser: false, message: "...", date: DateTime.now()));
      _isLoading = true;
    });

      try {
      // Replace the HTTP request to OpenAI with a call to your GeminiAI class
      String response = await GeminiAI.generateResponse(message);

      setState(() {
        _messages.removeLast();
        _messages.add(Message(isUser: false, message: response, date: DateTime.now()));
        _isLoading = false;
      });

      await _currentChatDocRef.collection('messages').add({
        'sender': 'user',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _currentChatDocRef.collection('messages').add({
        'sender': 'bot',
        'message': response,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNewChat() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(46),
        child: AppBar(
        title: const Text(
          'UniSara AI',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 12, 6),
              child: SizedBox(
                width: 28,
                height: 28,
                child: FloatingActionButton(
                  onPressed: _navigateToNewChat,
                  backgroundColor: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Image.asset('assets/newChat.png'),
                  ),
                  mini: true,
                  elevation: 0.0,
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: FirebaseAuth.instance.currentUser != null ? CustomDrawer() : SecondDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Messages(
                      key: ValueKey(index),
                      isUser: message.isUser,
                      message: message.message,
                      date: message.date,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 8 * 20.0,
                        ),
                        child: SingleChildScrollView(
                          child: TextField(
                            controller: _userMessage,
                            maxLines: null,
                            minLines: 1,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(width: 2.0),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              labelText: 'Message',
                              labelStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                              contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            ),
                            onChanged: (text) {
                              _userMessage.selection = TextSelection.fromPosition(
                                  TextPosition(offset: _userMessage.text.length));
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 50,
                      child: IconButton(
                        onPressed: _isLoading ? null : sendMessage,
                        icon: const Icon(Icons.send),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 70,
            left: MediaQuery.of(context).size.width / 2 - (35 / 2),
            child: SizedBox(
              width: 30,
              height: 30,
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                backgroundColor: Color.fromARGB(255, 0, 0, 0),
                elevation: 4,
                mini: true,
                heroTag: null,
                child: Image.asset('assets/ic_launcherV3.png', width: 38, height: 38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final DateTime date;

  const Messages({
    Key? key,
    required this.isUser,
    required this.message,
    required this.date,
  }) : super(key: key);

   @override
  Widget build(BuildContext context) {
    final String senderName = isUser ? "You" : "UniSara";
    final String userInitial = isUser ? "Y" : senderName[0];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                isUser
                    ? CircleAvatar(
                        backgroundColor: const Color.fromARGB(255, 0, 37, 67),
                        radius: 10,
                        child: Text(
                          userInitial,
                          style: const TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      )
                    : Image.asset(
                        'assets/ic_launcherV2.png',
                        width: 20,
                        height: 20,
                      ),
                const SizedBox(width: 8),
                Text(
                  senderName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 42.0, right: 30.0),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}