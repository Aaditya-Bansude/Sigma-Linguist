import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigma_linguist/chat/chat.dart';
import 'package:sigma_linguist/utility/utility.dart';
import 'drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _reference = FirebaseFirestore.instance.collection('Linguist-Chats');

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatNotifier>(
      builder: (context, chatNotifier, child) {
        DocumentSnapshot? recentChat = chatNotifier.recentChat;
        return Scaffold(
          body: StreamBuilder(
            stream: _reference.orderBy('Timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                List<QueryDocumentSnapshot> allChats = snapshot.data!.docs;
                if (allChats.isNotEmpty) {
                  recentChat ?? context.read<ChatNotifier>().updateRecentChat(allChats.first);
                }
                return Scaffold(
                  appBar: AppBar(
                    iconTheme: const IconThemeData(color: Colors.deepPurple),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: Container(
                        color: Colors.deepPurple,
                        height: 1,
                      )
                    ),
                    title: const Text(
                      'Sigma Linguist',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                      ),
                    ),
                  ),
                  drawer: ChatDrawer(
                    context: context,
                    reference: _reference,
                    allChats: allChats,
                    selectedChat: (selectedChat) => context.read<ChatNotifier>().updateRecentChat(selectedChat),
                  ),
                  body: ChatScreen(
                    reference: _reference,
                  ),
                );
              }
              return Container();
            },
          )
        );
      }
    );
  }
}
