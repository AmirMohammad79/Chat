import 'package:flutter/material.dart';
import 'package:chat1/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
final _firestore = FirebaseFirestore.instance;
User loggedInUser;
class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String message;
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
           MessageStreams(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore
                          .collection('messages')
                          .add({'text': message, 'sender': loggedInUser.email , 'time':DateTime.now().toString()});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessageStreams extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy("time").snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: snapshot.data.docs.reversed
                .map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data() as Map<String, dynamic>;
              final currentUser = loggedInUser.email;
              data['time'] = DateTime.now().toString();
              final bool isMe = currentUser==data['sender'];
              return Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  MessagesBubble(
                    text: data['text'],
                    isMe: currentUser==data['sender'],
                  ),
                  Padding(
                    padding: isMe ? EdgeInsets.only(right: 15.0) : EdgeInsets.only(left: 15.0),
                    child: Text(
                      data['sender'],
                      style: TextStyle(color: Colors.black45),
                    ),
                  )
                ],
              );
            })
                .toList()
                .cast(),
          ),
        );
      },
    );
  }
}


class MessagesBubble extends StatelessWidget {
  MessagesBubble({this.text,this.isMe});
  final String text;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Material(
        elevation: 7,
        borderRadius:isMe ?  BorderRadius.only(topLeft: Radius.circular(20.0) , bottomLeft: Radius.circular(20.0)) : BorderRadius.only(topRight: Radius.circular(20.0) , bottomRight: Radius.circular(20.0)),
        color: isMe ? Colors.lightBlueAccent : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Text(
            text,
            style: TextStyle(color: isMe ?  Colors.white : Colors.black54, fontSize: 15.0),
          ),
        ),
      ),
    );
  }
}
