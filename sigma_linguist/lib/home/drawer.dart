import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatDrawer extends StatefulWidget {
  final BuildContext context;
  final CollectionReference reference;
  final List<QueryDocumentSnapshot> allChats;
  final Function(DocumentSnapshot) selectedChat;

  const ChatDrawer({
    super.key,
    required this.context,
    required this.reference,
    required this.allChats,
    required this.selectedChat
  });

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  late List<TextEditingController> chatNameControllers;
  late List<bool> renaming;

  void _createNewChat() async {
    DocumentReference newChat = await widget.reference.add({
      'Name': 'Untitled Chat',
      'Messages': [],
      'Timestamp': DateTime.now(),
    });
    widget.selectedChat(await newChat.get());
  }

  void _renameChat(DocumentSnapshot chat, String chatName, int index) async {
    await chat.reference.update({
      'Name': chatName,
    }).then((_) {
      setState(() {
        renaming[index] = false;
      });
    });
  }

  void _deleteChat(DocumentSnapshot chat) async {
    await chat.reference.delete().then((_) {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    chatNameControllers = widget.allChats.map(
      (chat) => TextEditingController(text: chat['Name'])
    ).toList();
    renaming = List.filled(widget.allChats.length, false);
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in chatNameControllers) { controller.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('User'),
            accountEmail: const Text('user@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/profile_background.jpg'),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("New Chat"),
            onTap: () {
              _createNewChat();
              Navigator.pop(context);
            },
          ),ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () { },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              'chats',
              style: TextStyle(
                 color: Colors.black54,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 0),
            itemCount: widget.allChats.length,
            itemBuilder: (context, index) {
              var chat = widget.allChats[index];
              return ListTile(
                title: renaming[index] ?
                  TextField(
                    controller: chatNameControllers[index],
                    autofocus: true,
                    onSubmitted: (_) => _renameChat(chat, chatNameControllers[index].text, index),
                  )
                    :
                  Text(chat['Name']),
                onTap: () {
                  widget.selectedChat(chat);
                  Navigator.pop(context);
                },
                trailing: GestureDetector(
                  child: const Icon(Icons.arrow_drop_down),
                  onTapDown: (details) {
                    var pos = Offset(details.globalPosition.dx, details.globalPosition.dy);
                    _showOptions(
                      context, pos,
                      (selected) => selected == 'delete' ? 
                        _deleteChat(chat) 
                          : 
                        setState(() {
                          renaming[index] = true;
                        }),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

void _showOptions(BuildContext context, Offset pos, Function(String) selected) {
  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (BuildContext context) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: (details) {
        overlayEntry!.remove();
      },
      onHorizontalDragEnd: (details) {
        overlayEntry!.remove();
      },
      child: Stack(
        children: [
          Positioned(
            top: pos.dy,
            left: pos.dx,
            child: Material(
              elevation: 4.0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width*0.25,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Rename'),
                      onTap: () {
                        selected('rename');
                        overlayEntry!.remove();
                      },
                    ),
                    ListTile(
                      title: const Text('Delete'),
                      onTap: () {
                        selected('delete');
                        overlayEntry!.remove();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);
}
