import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';
import '../authentication/auth_service.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final AuthService authService = AuthService(); // Initialize AuthService

  @override
  Widget build(BuildContext context) {
    var radius = 18.0;
    String avatarUrl =
        FirebaseAuth.instance.currentUser?.photoURL ?? "http://via.placeholder.com/200x300";
    String userName = FirebaseAuth.instance.currentUser?.displayName ?? "Logged in as";
    String userEmail = FirebaseAuth.instance.currentUser?.email ?? "no email found";

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: const Color.fromARGB(255, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 0, 0, 0),
                    hintText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.grey.shade200,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Text(
                'Unisara AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: _fetchChatHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(); // Return an empty container instead of CircularProgressIndicator
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container();
                } else {
                  final today = DateTime.now();
                  final yesterday = today.subtract(Duration(days: 1));
                  final weekAgo = today.subtract(Duration(days: 7));

                  final todayChats = snapshot.data!.docs.where((doc) {
                    final timestamp = (doc['timestamp'] as Timestamp?)?.toDate();
                    return timestamp != null &&
                        timestamp.isAfter(DateTime(today.year, today.month, today.day));
                  }).toList();

                  final yesterdayChats = snapshot.data!.docs.where((doc) {
                    final timestamp = (doc['timestamp'] as Timestamp?)?.toDate();
                    return timestamp != null &&
                        timestamp.isAfter(DateTime(yesterday.year, yesterday.month, yesterday.day)) &&
                        timestamp.isBefore(DateTime(today.year, today.month, today.day));
                  }).toList();

                  final weekAgoChats = snapshot.data!.docs.where((doc) {
                    final timestamp = (doc['timestamp'] as Timestamp?)?.toDate();
                    return timestamp != null &&
                        timestamp.isAfter(weekAgo) &&
                        timestamp.isBefore(DateTime(yesterday.year, yesterday.month, yesterday.day));
                  }).toList();

                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16), // Add padding to ListView
                    children: [
                      if (todayChats.isNotEmpty) ...[
                        ListTile(
                          title: Text(
                            'Today',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('Chats from today'),
                        ),
                        ...todayChats.map((doc) => _buildChatTile(context, doc)).toList(),
                      ],
                      if (yesterdayChats.isNotEmpty) ...[
                        ListTile(
                          title: Text(
                            'Yesterday',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('Chats from yesterday'),
                        ),
                        ...yesterdayChats.map((doc) => _buildChatTile(context, doc)).toList(),
                      ],
                      if (weekAgoChats.isNotEmpty) ...[
                        ListTile(
                          title: Text(
                            'Last 7 Days',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('Chats from the past week'),
                        ),
                        ...weekAgoChats.map((doc) => _buildChatTile(context, doc)).toList(),
                      ],
                    ],
                  );
                }
              },
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              radius: radius,
              backgroundImage: CachedNetworkImageProvider(avatarUrl),
              backgroundColor: Theme.of(context).cardColor,
            ),
            title: Text(userName),
            subtitle: Text(userEmail),
            onTap: null, // Make it non-clickable
            trailing: IconButton(
              icon: Icon(Icons.logout), // Replace three dots with logout icon
              onPressed: _confirmSignOut, // Call sign-out confirmation method
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to sign out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _signOut(context); // Call sign-out method
              },
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await authService.signOut(); // Call the sign-out method from AuthService
      Navigator.of(context).popUntil((route) => route.isFirst); // Pop the settings page
    } catch (e) {
      print("Error occurred during sign-out: $e");
      // Handle error gracefully
    }
  }

  Widget _buildChatTile(BuildContext context, DocumentSnapshot doc) {
    final chatData = doc.data() as Map<String, dynamic>;
    final timestamp = (chatData['timestamp'] as Timestamp?)?.toDate();
    final formattedDate = timestamp != null ? DateFormat('yyyy-MM-dd – kk:mm').format(timestamp) : 'Unknown Date';
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context, doc),
      child: ListTile(
        title: Text(formattedDate),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(chatId: doc.id),
            ),
          );
        },
      ),
    );
  }

  Future<QuerySnapshot> _fetchChatHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('chat_history')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, DocumentSnapshot doc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Chat Session?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this chat session?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Implement deletion logic here
                _deleteChatSession(doc).then((_) {
                  setState(() {}); // Refresh the UI after deletion
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteChatSession(DocumentSnapshot doc) async {
    // Implement logic to delete the chat session
    String chatId = doc.id;
    await FirebaseFirestore.instance.collection('chat_history').doc(chatId).delete();
    print('Chat session deleted successfully.');
  }
}
