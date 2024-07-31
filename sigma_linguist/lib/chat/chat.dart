import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import 'package:sigma_linguist/utility/utility.dart';

class ChatScreen extends StatefulWidget {
  final CollectionReference reference;
  const ChatScreen({
    super.key,
    required this.reference,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final messageControllerFocus = FocusNode();
  final String gemmaUrl = "https://api-inference.huggingface.co/models/google/gemma-2b-it";
  final String? gemmaToken = dotenv.env['Gemma_Token'];
  late bool fetching = false;

  void _handleRequest(DocumentSnapshot? recentChat, String sender, String content) async {
    if (recentChat != null && (await widget.reference.doc(recentChat.id).get()).exists) {
      _addMessage(recentChat, sender, content);
      _getResponse(recentChat, content);
    } else {
      DocumentReference newChatRef = await widget.reference.add({
        'Name': 'Untitled Chat',
        'Messages': [{'sender': sender, 'content': content, 'timestamp': DateTime.now()}],
        'Timestamp': DateTime.now(),
      });
      DocumentSnapshot newChat = await newChatRef.get();
      _getResponse(newChat, content);
      context.read<ChatNotifier>().updateRecentChat(newChat);
    }
  }

  void _addMessage(DocumentSnapshot recentChat, String sender, String content) async {
    await widget.reference.doc(recentChat.id).update({
      'Messages': FieldValue.arrayUnion([
        {'sender': sender, 'content': content, 'timestamp': DateTime.now()}
      ])
    });
  }

  void _getResponse(DocumentSnapshot recentChat, String query) async {
    bool retry = false;
    setState(() {
      fetching = true;
    });

    do {
      final Response response = await post(
        Uri.parse(gemmaUrl),
        headers: {
          'Authorization': 'Bearer $gemmaToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputs': 'Convert the following phrase into more appropriate and grammatically correct corporate language phrase: $query',
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> responseBody = json.decode(response.body);
        String responseText = responseBody[0]['generated_text'];
        responseText = responseText.replaceFirst(
          'Convert the following phrase into more appropriate and grammatically correct corporate language phrase: $query',
          '',
        ).trim();
        _addMessage(recentChat, 'sigma linguist', responseText);
        retry = false;
        setState(() {
          fetching = false;
        });
      } else if (response.statusCode == 503) {
        _addMessage(recentChat, 'sigma linguist', 'Taking Longer Than Usual Fetching Response...');
        await Future.delayed(const Duration(seconds: 100));
        retry = true;
      } else {
        _addMessage(recentChat, 'sigma linguist', '${response.statusCode.toString()}: Error Fetching Response!');
        setState(() {
          fetching = false;
        });
      }
    } while (retry);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatNotifier>(builder: (context, chatNotifier, child) {
      DocumentSnapshot? recentChat = chatNotifier.recentChat;
      return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (recentChat != null)
              StreamBuilder(
                  stream: recentChat.reference.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {

                    } else if (snapshot.hasData && snapshot.data!.exists) {
                      List<dynamic> messages = snapshot.data!.get('Messages');
                      List<ChatMessage> chatMessages = [];
                      if (messages.isNotEmpty) {
                        messages.sort((a, b) {
                          Timestamp timestampA = a['timestamp'] as Timestamp;
                          Timestamp timestampB = b['timestamp'] as Timestamp;
                          return timestampB.compareTo(timestampA);
                        });
                        for (var message in messages) {
                          final sender = message['sender'];
                          final content = message['content'];
                          chatMessages.add(
                              ChatMessage(content: content, sender: sender));
                        }
                        return Expanded(
                          child: ListView(
                            reverse: true,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            children: chatMessages,
                          ),
                        );
                      }
                    }
                    return Container();
                  }),
            if (fetching)
              PreferredSize(
                preferredSize: const Size(25, 10),
                child: Container(
                  constraints: const BoxConstraints.expand(height: 1.0),
                  child: Utility.loadingAnimation(true),
                ),
              ),
            Container(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Material(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: TextField(
                          controller: messageController,
                          decoration: Utility.messageInputDecoration(),
                        ),
                      ),
                    ),
                  ),
                  MaterialButton(
                      shape: const CircleBorder(),
                      color: Colors.blue,
                      onPressed: () {
                        String message = messageController.text;
                        messageController.clear();
                        _handleRequest(recentChat, 'user', message);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(Icons.send, color: Colors.white),
                      )),
                ],
              ),
            ),
          ]);
    });
  }
}

class ChatMessage extends StatelessWidget {
  final String content;
  final String sender;
  const ChatMessage({
    super.key,
    required this.content,
    required this.sender,
  });

  @override
  Widget build(BuildContext context) {
    final bool user = sender == 'user';
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment:
            user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              sender,
              style: const TextStyle(
                  fontSize: 12, fontFamily: 'Poppins', color: Colors.black87
              ),
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(50),
              topLeft:
                  user ? const Radius.circular(50) : const Radius.circular(0),
              bottomRight: const Radius.circular(50),
              topRight:
                  user ? const Radius.circular(0) : const Radius.circular(50),
            ),
            color: user ? Colors.blue : Colors.deepPurple,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                content,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
