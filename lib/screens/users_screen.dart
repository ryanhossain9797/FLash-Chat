import 'package:flash_chat/arguments/chat_screen_args.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
final _auth = FirebaseAuth.instance;
FirebaseUser currentUser;

class UsersScreen extends StatefulWidget {
  static const String id = '/users';

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        currentUser = user;
        print(currentUser.email);
      }
    } catch (e) {
      print('error occured $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[UsersStreamBuilder()]),
      ),
    );
  }
}

class UsersStreamBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, asSnapshot) {
        if (!asSnapshot.hasData || currentUser == null) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        } else {
          var users = asSnapshot.data.documents.reversed;
          List<Widget> usersList = [];
          for (var user in users) {
            final String email = user['email'];
            final String username = user['username'];
            if (email != currentUser.email) {
              usersList.add(
                InkWell(
                  onTap: () {
                    ChatScreenArgs arg = ChatScreenArgs(email: email);
                    Navigator.pushNamed(context, ChatScreen.id, arguments: arg);
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.transparent, width: 5),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 25),
                      child: Center(
                        child: Text(
                          email,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
          return Expanded(
            child: ListView(
              children: usersList,
            ),
          );
        }
      },
    );
  }
}
