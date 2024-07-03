import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Utility {
  static messageInputDecoration() {
    return const InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      hintText: 'Type your message here...',
      hintStyle: TextStyle(fontFamily: 'Poppins',fontSize: 14),
      border: InputBorder.none,
    );
  }

  static loadingAnimation(bool loading) {
    return loading ?
      const LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        backgroundColor: Colors.lightBlueAccent,
      )
        :
      null;
  }
}

class Clipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;
    var path = Path();
    path.lineTo(0, 0);
    path.quadraticBezierTo(width/2, height, width, height);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ChatNotifier extends ChangeNotifier {
  DocumentSnapshot? _recentChat;
  DocumentSnapshot? get recentChat => _recentChat;

  void updateRecentChat(DocumentSnapshot newChat) {
      _recentChat = newChat;
      notifyListeners();
  }
}

