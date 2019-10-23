import 'package:flutter/material.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/arguments/chat_screen_args.dart';
import 'package:rxdart/rxdart.dart';

final _firestore = Firestore.instance;
final _auth = FirebaseAuth.instance;
FirebaseUser currentUser;
String recepient;

class ChatScreen extends StatefulWidget {
  static const String id = '/chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String currentMessage;

  @override
  void initState() {
    getUser();
    //messageStream();
    super.initState();
  }

  void getUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          currentUser = user;
        });
        print(currentUser.email);
      }
    } catch (e) {
      print('error occured $e');
    }
  }

  //Useless method for testing only
  // void messageStream() async {
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     for (var message in snapshot.documents) {
  //       print(message.data);
  //     }
  //   }
  // }

  //Useless method for testing only
  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').getDocuments();
  //   for (var message in messages.documents) {
  //     print(message.data);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final ChatScreenArgs arg = ModalRoute.of(context).settings.arguments;
    recepient = arg.email;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //_auth.signOut();
                //Navigator.pop(context);
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
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.lightBlueAccent,
              child: Center(
                child: Text(recepient),
              ),
            ),
            MessageStreamBuilder(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        currentMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      _firestore.collection('messages').add({
                        'sender': currentUser.email,
                        'receiver': recepient,
                        'content': currentMessage,
                      });
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

class MessageStreamBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.lightBlueAccent,
        ),
      );
    }
    Stream<QuerySnapshot> sentStream = _firestore
        .collection('messages')
        .where('sender', isEqualTo: currentUser.email)
        .where('receiver', isEqualTo: recepient)
        .snapshots();
    Stream<QuerySnapshot> receivedStream = _firestore
        .collection('messages')
        .where('sender', isEqualTo: recepient)
        .where('receiver', isEqualTo: currentUser.email)
        .snapshots();

    var obs = Observable.merge([sentStream, receivedStream]);
    return StreamBuilder<QuerySnapshot>(
      stream: sentStream,
      builder: (context, asSnapshot) {
        if (!asSnapshot.hasData || currentUser == null) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        } else {
          var messages = asSnapshot.data.documents.reversed;
          List<Padding> messageWidgets = [];
          for (var msg in messages) {
            final msgTxt = msg['content'];
            final msgSender = msg['sender'];
            final currentUserEmail = currentUser.email;

            messageWidgets.add(
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: MessageBubble(
                  content: msgTxt,
                  username: msgSender,
                  isMe: currentUserEmail == msgSender,
                ),
              ),
            );
          }
          print(messageWidgets);
          return Expanded(
            child: ListView(
              reverse: true,
              children: messageWidgets,
            ),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String username;
  final String content;
  final bool isMe;

  MessageBubble({this.username, this.content, this.isMe});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            username,
            textAlign: TextAlign.right,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(isMe ? 20 : 0),
                topRight: Radius.circular(isMe ? 0 : 20),
              ),
              color: isMe ? Colors.lightBlueAccent : Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                content,
                style: TextStyle(
                    fontSize: 20, color: isMe ? Colors.white : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
