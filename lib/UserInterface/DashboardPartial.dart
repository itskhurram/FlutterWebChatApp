import 'dart:async';

import 'package:myuwi/Repository/DatabaseHandler.dart';
import 'package:myuwi/UserInterface/DashboardSplit.dart';
import 'package:myuwi/Values/AppValues.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:linkable/linkable.dart';

class DashboardPartial extends StatefulWidget {
  //DashboardPartial({Key key}) : super(key: key);
  final String questionId;
  DashboardPartial({this.questionId});

  @override
  _DashboardPartialState createState() => _DashboardPartialState();
}

class _DashboardPartialState extends State<DashboardPartial> {
  DatabaseHandler databaseHandler = new DatabaseHandler();
  String firstName = "";
  String lastName = "";
  String emailAddress = "";
  String courseCode = "";
  String myUserName = "";
  ScrollController controller;
  bool _isLoading;
  int numberOfUniquePeopleCall = 0;
  int millisecondsSpent = 0;
  String studentDocumentId = "";
  Stream<QuerySnapshot> _data;
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
    if (html.window.sessionStorage != null &&
        html.window.sessionStorage['documentId'] != null) {
      studentDocumentId = html.window.sessionStorage['documentId'];
    }
    _isLoading = true;
     _getData();
  }
  Future<Null> _getData() async {
    await databaseHandler
        .getQuestionListbyCourseCodePageStream("Question", emailAddress)
        .then((val) {
      setState(() {
        _isLoading = false;
        _data = val;
      });
    });
  }
  getLeftMenuItems() async {
    await databaseHandler
        .getLeftMenuItemsTime(myUserName.toUpperCase())
        .then((value) {
      millisecondsSpent = 0;
      List<String> userList = [];
      for (var doc in value.docs) {
        if (doc.data()['totalMilliSecondsSpent'] != null) 
            millisecondsSpent += doc.data()['totalMilliSecondsSpent'];
        if (!userList.contains(doc.data()['fromUser'])) {
          userList.add(doc.data()['fromUser']);
        }
      }
      numberOfUniquePeopleCall = userList.length;
    });
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
        getLeftMenuItems();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: new RefreshIndicator(
        child: StreamBuilder(
            stream: _data,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        if ((snapshot.data.docs[index]
                                    .data()['activityStarted'] ==
                                false) &&
                            ((int.parse(snapshot.data.docs[index]
                                        .data()['createdDate']
                                        .toString()) +
                                    (3 * 86400000)) <
                                (DateTime.now().millisecondsSinceEpoch))) {
                          return Container();
                        } else {
                          return Container(
                            child: Card(
                                color:  snapshot.data.docs[index].id ==
                                      widget.questionId
                                  ? Colors.orange
                                  : Colors.white,
                                child: ListTile(
                                  leading: Container(
                                    child: Icon(
                                      Icons.account_circle,
                                      color: AppColors.ucDavisBlue,
                                    ),
                                  ),
                                  title: Text("(" +
                                      snapshot.data.docs[index]
                                          .data()['courseCode'] +
                                      ") " +
                                      snapshot.data.docs[index]
                                          .data()['question'],
                                          style: TextStyle(
                                            fontWeight: ((snapshot.data.docs[index]
                                          .data()['hasChatMessagesFromOwner']=="true" && snapshot.data.docs[index]
                                          .data()['email'] != emailAddress) || (snapshot.data.docs[index]
                                          .data()['hasChatMessagesForOwner']=="true" && snapshot.data.docs[index]
                                          .data()['email'] == emailAddress)) ? FontWeight.bold : FontWeight.normal
                                            
                                            
                                            )),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Visibility(
                                          visible: (snapshot.data.docs[index]
                                                  .data()['email']
                                                  .toString()
                                                  .toLowerCase() ==
                                              emailAddress.toLowerCase()),
                                          child: IconButton(
                                            color: AppColors.ucDavisGreen,
                                            icon: Icon(Icons.verified_user),
                                            tooltip: "Mark Resolved",
                                            onPressed: () {
                                              databaseHandler
                                                  .markQuestionResolved(
                                                      "Question",
                                                      snapshot
                                                          .data.docs[index].id);
                                            },
                                          )),
                                           Visibility(
                                          visible: getIconVisibility(snapshot.data.docs[index]),
                                          child: Icon(
                                            Icons.star,
                                            color: AppColors.ucDavisYellow,
                                          ),
                                        ),
                                      Visibility(
                                          visible: (snapshot.data.docs[index]
                                                  .data()['email']
                                                  .toString()
                                                  .toLowerCase() ==
                                              emailAddress.toLowerCase()),
                                          child: (snapshot.data.docs[index]
                                                              .data()[
                                                          'ownerMessageCounter'] !=
                                                      null &&
                                                  snapshot.data.docs[index]
                                                          .data()[
                                                              'ownerMessageCounter']
                                                          .toString()
                                                          .toLowerCase() !=
                                                      "0")
                                              ? Badge(
                                                  badgeColor:
                                                      AppColors.ucDavisBlue,
                                                  badgeContent: Text(
                                                      snapshot.data.docs[index]
                                                          .data()[
                                                              'ownerMessageCounter']
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .ucDavisWhite)),
                                                  child: IconButton(
                                                    color: snapshot.data
                                                                    .docs[index]
                                                                    .data()[
                                                                'hasChatMessagesForOwner'] ==
                                                            "true"
                                                        ? AppColors.ucDavisGreen
                                                        : AppColors.ucDavisBlue,
                                                    icon: Icon(Icons.chat),
                                                    onPressed: () {
                                                      sendMessage(
                                                          snapshot
                                                              .data.docs[index]
                                                              .data()['email'],
                                                          snapshot.data
                                                                  .docs[index]
                                                                  .data()[
                                                              'courseCode'],
                                                          snapshot.data
                                                              .docs[index].id);
                                                    },
                                                  ),
                                                )
                                              : IconButton(
                                                  color: snapshot.data
                                                                  .docs[index]
                                                                  .data()[
                                                              'hasChatMessagesForOwner'] ==
                                                          "true"
                                                      ? AppColors.ucDavisGreen
                                                      : AppColors.ucDavisBlue,
                                                  icon: Icon(Icons.chat),
                                                  onPressed: () {
                                                    sendMessage(
                                                        snapshot
                                                            .data.docs[index]
                                                            .data()['email'],
                                                        snapshot.data
                                                                .docs[index]
                                                                .data()[
                                                            'courseCode'],
                                                        snapshot.data
                                                            .docs[index].id);
                                                  },
                                                )),
                                      Visibility(
                                          visible: snapshot.data.docs[index]
                                                  .data()['email']
                                                  .toString()
                                                  .toLowerCase() !=
                                              emailAddress.toLowerCase(),
                                          child: IconButton(
                                              icon: Icon(Icons.chat,
                                                  color: snapshot.data
                                                                  .docs[index]
                                                                  .data()[
                                                              'hasChatMessagesFromOwner'] ==
                                                          "true"
                                                      ? AppColors.ucDavisGreen
                                                      : AppColors.ucDavisBlue),
                                              color: AppColors.ucDavisBlue,
                                              onPressed: () {
                                                sendMessage(
                                                    snapshot.data.docs[index]
                                                        .data()['email'],
                                                    snapshot.data.docs[index]
                                                        .data()['courseCode'],
                                                    snapshot
                                                        .data.docs[index].id);
                                              })),
                                      Container(
                                        child: IconButton(
                                            icon: Icon(Icons.video_call,
                                                color: AppColors.ucDavisBlue),
                                            onPressed: () {
                                              var isOwner = snapshot
                                                      .data.docs[index]
                                                      .data()['email']
                                                      .toString()
                                                      .toLowerCase() ==
                                                  emailAddress.toLowerCase();
                                              js.context
                                                  .callMethod('joinCall', [
                                                snapshot.data.docs[index].id,
                                                snapshot.data.docs[index]
                                                    .data()['email']
                                                    .toString()
                                                    .toLowerCase(),
                                                firstName,
                                                lastName,
                                                emailAddress,
                                                isOwner
                                              ]);
                                            }),
                                      )
                                    ],
                                  ),
                                )),
                          );
                        }
                      })
                  : Container();
            },
          ),
          onRefresh: () async {
            _data = null;
            //await _getData();
            await getLeftMenuItems();
          },
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Container(
                    child: new CircleAvatar(
                  child: Icon(
                    Icons.person_outline,
                    size: 140,
                    color: AppColors.ucDavisBlue,
                  ),
                  backgroundColor: AppColors.white,
                )),
                decoration: BoxDecoration(color: AppColors.ucDavisBlue),
              ),
              Card(
                child: ListTile(
                  tileColor: AppColors.ucDavisYellow,
                  title: Text("Hours logged = " + getSpentTimeLeftManu()),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Card(
                child: ListTile(
                  tileColor: AppColors.ucDavisYellow,
                  title: Text(
                      'Users helped = ' + numberOfUniquePeopleCall.toString()),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
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

  //Chat Related Stuff
  getChatRoomId(
      String questionOwnerUsername, String courseCode, String questionId) {
    return "$questionOwnerUsername\_$courseCode\_$questionId";
  }

  String getSpentTimeLeftManu() {
    if (millisecondsSpent == 0 || millisecondsSpent == null) {
      return "00:00:00";
    } else {
      return new Duration(
              days: 0,
              hours: 0,
              minutes: 0,
              seconds: 0,
              milliseconds: millisecondsSpent)
          .toString()
          .split('.')[0];
    }
  }

  sendMessage(String questionOwneremail, String courseCode, String questionId) {
    String myUserName = emailAddress.substring(0, emailAddress.indexOf("@"));
    String questionOwnerUsername = questionOwneremail.substring(0, questionOwneremail.indexOf("@"));
    databaseHandler.getStudentsbyCourse(courseCode).then((val) {
      List<String> userList = [];
      if (val != null && val.docs.length > 0) {
        for (var doc in val.docs) {
          String userEmail = doc.data()['email'];
          String memberuserName =
              userEmail.substring(0, userEmail.indexOf("@"));
          userList.add(memberuserName);
        }
        String chatRoomId = getChatRoomId(questionOwnerUsername, courseCode, questionId);

        Map<String, dynamic> chatRoom = {
          "userList": userList,
          "chatRoomId": chatRoomId,
          "questionId": questionId,
          "groupName": courseCode + '_' + questionOwnerUsername,
          "createdDate": DateTime.now().millisecondsSinceEpoch
        };
        databaseHandler.addChatRoom(chatRoom, chatRoomId,myUserName==questionOwnerUsername);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardSplit(
                      chatRoomId: chatRoomId,
                    )));
                    
      }
    });
  }
  getIconVisibility(doc) {
    if (doc != null) {
      if (doc.data()['participatedEmail'].toString().contains(emailAddress)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
