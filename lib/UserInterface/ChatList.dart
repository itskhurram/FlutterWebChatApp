import 'package:myuwi/Repository/DatabaseHandler.dart';
import 'package:myuwi/UserInterface/AddCourse.dart';
import 'package:myuwi/UserInterface/AskQuestion.dart';
import 'package:myuwi/UserInterface/Chat.dart';
import 'package:myuwi/UserInterface/Signin.dart';
import 'package:myuwi/Values/AppValues.dart';
import 'package:myuwi/Widgets/AppSpaces.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:linkable/linkable.dart';

class ChatList extends StatefulWidget {
  //ChatList({Key key}) : super(key: key);
  final String questionId;
  ChatList({this.questionId});

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  DatabaseHandler databaseHandler = new DatabaseHandler();
  String firstName = "";
  String lastName = "";
  String emailAddress = "";
  String courseCode = "";
  String myUserName = "";
  ScrollController controller;
  DocumentSnapshot _lastVisible;
  bool _isLoading;
  List<DocumentSnapshot> _data =  [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
   controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    if (html.window.sessionStorage != null &&
        html.window.sessionStorage['email'] != null) {
      emailAddress = html.window.sessionStorage['email'];
      myUserName = emailAddress.substring(0, emailAddress.indexOf("@"));
    }
    if (html.window.sessionStorage != null &&
        html.window.sessionStorage['lastName'] != null) {
      lastName = html.window.sessionStorage['lastName'];
    }
    if (html.window.sessionStorage != null &&
        html.window.sessionStorage['firstName'] != null) {
      firstName = html.window.sessionStorage['firstName'];
    }
    _isLoading = true;
    getChatList();
  }
  Future<Null> getChatList() async {
    QuerySnapshot data = await databaseHandler.searchChatRoomsByQuestionId(
        "ChatRoom", widget.questionId, 10, _lastVisible);
    if (data != null && data.docs.length > 0) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _data.addAll(data.docs);
        });
      }
    } else {
      setState(() => _isLoading = false);
      // ignore: deprecated_member_use
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('No more posts!'),
        ),
      );
    }
    return null;
  }
 @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        getChatList();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
        return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: AppColors.ucDavisBlue,
          iconTheme: new IconThemeData(color: AppColors.ucDavisWhite),
          actions: <Widget>[
            FlatButton.icon(
                icon: Icon(Icons.add_circle,
                    color: Colors.white, semanticLabel: 'Post Question'),
                label: Text("Post Question",
                    style: new TextStyle(
                        color: Colors.white,
                        fontFamily: 'Proxima Nova',
                        fontSize: 14)),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext ctx) => AskQuestion()));
                }),
            FlatButton.icon(
                icon: Icon(Icons.add_circle,
                    color: Colors.white, semanticLabel: 'Add Course'),
                label: Text("Add Course",
                    style: new TextStyle(
                        color: Colors.white,
                        fontFamily: 'Proxima Nova',
                        fontSize: 14)),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext ctx) => AddCourse()));
                }),
            //SpaceW16(),
            FlatButton.icon(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                  semanticLabel: 'Sign out',
                ),
                label: Text("Sign out",
                    style: new TextStyle(
                        color: Colors.white, fontFamily: 'Proxima Nova')),
                //color: Colors.white,
                onPressed: () {
                  html.window.sessionStorage['email'] = "";
                  html.window.sessionStorage['firstName'] = "";
                  html.window.sessionStorage['lastName'] = "";
                  html.window.sessionStorage.clear();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext ctx) => SignIn()));
                }),
          ],
          bottom: PreferredSize(
            child: new Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  SpaceW12(),
                  Container(
                    child: Text(lastName + ', ' + firstName,
                        style: new TextStyle(
                            fontFamily: 'Proxima Nova',
                            fontSize: 18.0,
                            color: Colors.white,
                            backgroundColor: null)),
                  )
                ],
              ),
            ),
            preferredSize: Size(0.0, 80.0),
          ),
        ),
        body: new RefreshIndicator(
          child: ListView.builder(
            controller: controller,
            itemCount: _data.length + 1,
            itemBuilder: (_, int index) {
              if (index < _data.length) {
                final DocumentSnapshot document = _data[index];
                return Container(
                  //height: 200.0,
                  child: Card(
                      child: ListTile(
                        leading: Container(
                          child: Icon(
                            Icons.account_circle,
                            color: AppColors.ucDavisBlue,
                          ),
                        ),
                        title: Text(document.data()['groupName']),
                        trailing: IconButton(
                                        color: AppColors.ucDavisGreen,
                                        icon: Icon(Icons.chat),
                                        onPressed: () {

                                             Navigator.push(context,MaterialPageRoute(builder: (context) => Chat(chatRoomId:document.data()['chatRoomId'])));
                                        },
                                      )
                      )),
                );
              }
              return Center(
                child: new Opacity(
                  opacity: _isLoading ? 1.0 : 0.0,
                  child: new SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: new CircularProgressIndicator()),
                ),
              );
            },
          ),
          onRefresh: () async {
            _data.clear();
            _lastVisible = null;
            await getChatList();
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Linkable(text: "Need support? support@karmacollab.com"),
                Text("Powered by KarmaCollab")
              ],
            ),
          ),
        ));
  }
}
