import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
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

  void _addMessage(DocumentSnapshot recentChat, String sender, String content) async {
    await widget.reference.doc(recentChat.id).update({
      'Messages': FieldValue.arrayUnion([{
        'sender': sender,
        'content': content,
        'timestamp': DateTime.now()
      }])
    });
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatNotifier>(
      builder: (context, chatNotifier, child) {
        DocumentSnapshot? recentChat = chatNotifier.recentChat;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if(recentChat != null)
              StreamBuilder(
                stream: recentChat.reference.snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return PreferredSize(
                      preferredSize: const Size(25, 10),
                      child: Container(
                        constraints: const BoxConstraints.expand(height: 1.0),
                        child: Utility.loadingAnimation(true),
                      ),
                    );
                  }
                  else if(snapshot.hasData) {
                    List<dynamic> messages = snapshot.data!.get('Messages');
                    List<ChatMessage> chatMessages = [];
                    if (messages.isNotEmpty) {
                      messages.sort((a, b) {
                        Timestamp timestampA = a['timestamp'] as Timestamp;
                        Timestamp timestampB = b['timestamp'] as Timestamp;
                        return timestampB.compareTo(timestampA);
                      });
                      for(var message in messages) {
                        final sender = message['sender'];
                        final content = message['content'];
                        chatMessages.add(
                          ChatMessage(
                            content: content,
                            sender: sender
                          )
                        );
                      }
                      return Expanded(
                        child: ListView(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          children: chatMessages,
                        ),
                      );
                    }
                  }
                  return Container();
                }
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
                      _addMessage(recentChat!, 'user', message, );
                    },
                    child:const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(Icons.send, color: Colors.white),
                    )
                  ),
                ],
              ),
            ),
          ]
        );
      }
    );
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
              style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', color: Colors.black87),
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(50),
              topLeft: user ? const Radius.circular(50) : const Radius.circular(0),
              bottomRight: const Radius.circular(50),
              topRight: user ? const Radius.circular(0) : const Radius.circular(50),
            ),
            color: user ? Colors.blue : Colors.white,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                content,
                style: TextStyle(
                  color: user ? Colors.white : Colors.blue,
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