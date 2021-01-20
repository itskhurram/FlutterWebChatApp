import 'dart:async';

import 'package:myuwi/Repository/DatabaseHandler.dart';
import 'package:myuwi/UserInterface/AddCourse.dart';
import 'package:myuwi/UserInterface/AskQuestion.dart';
import 'package:myuwi/UserInterface/DashboardSplit.dart';
import 'package:myuwi/UserInterface/Signin.dart';
import 'package:myuwi/Values/AppValues.dart';
import 'package:myuwi/Widgets/AppSpaces.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:linkable/linkable.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

enum NavLinks { Home, Github, Videos, Jobs }

class _DashboardState extends State<Dashboard> {
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
  final assetsAudioPlayer = new AssetsAudioPlayer();
  List<PopupMenuItem<dynamic>> notificationList =[];
  String notificationCount = "";

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
            PopupMenuButton(
                onSelected: (value) {
                  setState(() {
                    valuesSelected(value);
                  });
                },
                tooltip: "Notification",
                icon: Badge(
                  badgeColor: Colors.red,
                  badgeContent: Text(notificationCount,
                      style: TextStyle(color: AppColors.ucDavisWhite)),
                  showBadge:
                      (notificationCount == "0" || notificationCount == "")
                          ? false
                          : true,
                  child: Icon(Icons.notifications,
                      color: Colors.white, semanticLabel: 'Notifications'),
                ),
                itemBuilder: (BuildContext context) {
                  return notificationList;
                }),
            FlatButton.icon(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                  semanticLabel: 'Sign out',
                ),
                label: Text("Sign out",
                    style: new TextStyle(
                        color: Colors.white, fontFamily: 'Proxima Nova')),
                onPressed: () async {
                  String documentId = html.window.sessionStorage['documentId'];
                  int loginInTime =
                      (html.window.sessionStorage['loginInTime'] != "null" &&
                              html.window.sessionStorage['loginInTime'] != "")
                          ? int.parse(html.window.sessionStorage['loginInTime'])
                          : 0;
                  int totalLoggedInTime = (html
                                  .window.sessionStorage['totalLoggedInTime'] !=
                              "null" &&
                          html.window.sessionStorage['totalLoggedInTime'] != "")
                      ? int.parse(
                          html.window.sessionStorage['totalLoggedInTime'])
                      : 0;

                  await databaseHandler.updatelogoutTime(
                      documentId, loginInTime, totalLoggedInTime);
                  clearSessionStorage();
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
                                color: snapshot.data.docs[index]
                                            .data()['status']
                                            .toString()
                                            .toLowerCase() !=
                                        'resolved'
                                    ? Colors.white
                                    : Colors.green,
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
                                            
                                            
                                            ),),
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

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

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
    getAllNotificationList();
    getLeftMenuItems();
    _getData();
  }

  getAllNotificationList() async {
    Stream<QuerySnapshot> notificationStream =
        await databaseHandler.getAllNotificationStream(emailAddress);
    int previousCount = 0;

    notificationStream.forEach((field) {
      notificationList = [];
      if (field.docs.length > 0) {
        var headerMenu = new PopupMenuItem(
            //textStyle: new TextStyle(backgroundColor: AppColors.ucDavisBlue),
            value: "-1|0|0|0|0", //questionId,
            child: Container(
              //color: AppColors.ucDavisBlue,
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text("Dismiss All",
                      style: new TextStyle(
                          color: AppColors.googleRed,
                          fontFamily: 'Proxima Nova',
                          fontSize: 10))
                  //SpaceW8(),
                ],
              ),
            ));
        notificationList.add(headerMenu);
      }
      int len = 0;
      field.docs.asMap().forEach((index, data) {
        var menu = new PopupMenuItem(
            value: getConcatinatedValue(
              field.docs[index].data()['type'].toString(),
              field.docs[index].data()['toEmail'].toString(),
              field.docs[index].data()['courseCode'].toString(),
              field.docs[index].data()['questionId'].toString(),
              field.docs[index].id,
            ), //questionId,
            child: Container(
              padding: EdgeInsets.all(2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  field.docs[index].data()['type'] == 0
                      ? Icon(
                          Icons.notification_important_rounded,
                          color: AppColors.ucDavisBlue,
                          size: 15.0,
                        )
                      : Icon(
                          Icons.chat_outlined,
                          color: AppColors.green,
                          size: 15.0,
                        ),
                  SpaceW8(),
                  getNotificationText(field.docs[index]
                      .data()['notificationContent']
                      .toString()),
                  //SpaceW8(),
                ],
              ),
            ));
        len++;
        notificationList.add(menu);
      });
      setState(() {
        if (previousCount != int.parse(len.toString()) &&
            int.parse(len.toString()) > 0) {
          //assetsAudioPlayer.open(new Audio("assets/audios/question.mp3"));
          assetsAudioPlayer
              .open(new Audio("assets/audios/question.mp3"))
              .then((value) {})
              .catchError((e) {});
        }
        notificationCount = len.toString();
        previousCount = int.parse(notificationCount);

        try {
          if (SystemChrome != null) {
            SystemChrome.setApplicationSwitcherDescription(
                new ApplicationSwitcherDescription(
              label: (notificationCount != "0" && notificationCount != "")
                  ? "(" + notificationCount + ") KarmaCollab App"
                  : "KarmaCollab App",
            )).then((value) {}).catchError((error) {});
          }
        } catch (e) {
          //
        }
      });
    });
  }

  void valuesSelected(String concatenatedValue) {
    var valueList = concatenatedValue.split('|');
    if (valueList.length > 0) {
      if (valueList[0] == "-1") {
        databaseHandler.removeAllMyNotification(emailAddress);
      } else if (valueList[0] == "1") {
        sendMessageNotification(
            valueList[1], valueList[2], valueList[3], valueList[4]);
      } else {
        databaseHandler.removeNotification(valueList[4]);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext ctx) => Dashboard()));
      }
    }
  }

  String getConcatinatedValue(
    String type,
    String email,
    String courseCode,
    String questionId,
    String id,
  ) {
    return "$type\|$email\|$courseCode\|$questionId\|$id";
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
    Stream<QuerySnapshot> leftItemsStream = await databaseHandler
        .getLeftMenuItemsTimeStream((myUserName.toUpperCase()));

    leftItemsStream.forEach((field) {
      List<String> userList = [];
      int timespent = 0;
      field.docs.asMap().forEach((index, data) {
        if (field.docs[index].data()['totalMilliSecondsSpent'] != null)
          timespent += field.docs[index].data()['totalMilliSecondsSpent'];

        if (!userList.contains(field.docs[index].data()['fromUser'])) {
          userList.add(field.docs[index].data()['fromUser']);
        }
      });
      setState(() {
        numberOfUniquePeopleCall = userList.length;
        millisecondsSpent = timespent;
      });
    });
  }

  getLeftMenuItemsOnly() async {
    Stream<QuerySnapshot> leftItemsStream = await databaseHandler
        .getLeftMenuItemsTimeStream((myUserName.toUpperCase()));

    List<String> userList = [];
    int timespent = 0;
    leftItemsStream.forEach((field) {
      field.docs.asMap().forEach((index, data) {
        if (field.docs[index].data()['totalMilliSecondsSpent'] != null)
          timespent += field.docs[index].data()['totalMilliSecondsSpent'];

        if (!userList.contains(field.docs[index].data()['fromUser'])) {
          userList.add(field.docs[index].data()['fromUser']);
        }
      });
      setState(() {
        numberOfUniquePeopleCall = userList.length;
        millisecondsSpent = timespent;
      });
    });
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        getLeftMenuItems();
      }
    }
  }

  void clearSessionStorage() {
    html.window.sessionStorage['email'] = "";
    html.window.sessionStorage['firstName'] = "";
    html.window.sessionStorage['lastName'] = "";
    html.window.sessionStorage['clientToken'] = "";
    html.window.sessionStorage['documentId'] = "";
    html.window.sessionStorage['totalLoggedInTime'] = "";
    html.window.sessionStorage['loginInTime'] = "";
    html.window.sessionStorage.clear();
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
    String questionOwnerUsername =
        questionOwneremail.substring(0, questionOwneremail.indexOf("@"));
    databaseHandler.getStudentsbyCourse(courseCode).then((val) {
      List<String> userList = [];
      if (val != null && val.docs.length > 0) {
        for (var doc in val.docs) {
          String userEmail = doc.data()['email'];
          String memberuserName =
              userEmail.substring(0, userEmail.indexOf("@"));
          userList.add(memberuserName);
        }
        String chatRoomId =
            getChatRoomId(questionOwnerUsername, courseCode, questionId);

        Map<String, dynamic> chatRoom = {
          "userList": userList,
          "chatRoomId": chatRoomId,
          "questionId": questionId,
          "groupName": courseCode + '_' + questionOwnerUsername,
          "createdDate": DateTime.now().millisecondsSinceEpoch
        };
        databaseHandler.addChatRoom(
            chatRoom, chatRoomId, myUserName == questionOwnerUsername);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardSplit(
                      chatRoomId: chatRoomId,
                    )));
      }
    });
  }

  sendMessageNotification(String questionOwneremail, String courseCode,
    String questionId, notificationDocumentid) {
    String myUserName = emailAddress.substring(0, emailAddress.indexOf("@"));
    String questionOwnerUsername =
        questionOwneremail.substring(0, questionOwneremail.indexOf("@"));
    databaseHandler.removeNotification(notificationDocumentid);
    databaseHandler.getStudentsbyCourse(courseCode).then((val) {
      List<String> userList = [];
      if (val != null && val.docs.length > 0) {
        for (var doc in val.docs) {
          String userEmail = doc.data()['email'];
          String memberuserName =
              userEmail.substring(0, userEmail.indexOf("@"));
          userList.add(memberuserName);
        }
        String chatRoomId =
            getChatRoomId(questionOwnerUsername, courseCode, questionId);

        Map<String, dynamic> chatRoom = {
          "userList": userList,
          "chatRoomId": chatRoomId,
          "questionId": questionId,
          "groupName": courseCode + '_' + questionOwnerUsername,
          "createdDate": DateTime.now().millisecondsSinceEpoch
        };
        databaseHandler.addChatRoom(
            chatRoom, chatRoomId, myUserName == questionOwnerUsername);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardSplit(
                      chatRoomId: chatRoomId,
                    )));
      }
    });
  }

  getNotificationText(String string) {
    if (string.isNotEmpty && string.length > 35) {
      return Text(string.substring(0, 32) + "...",
          style: new TextStyle(
              color: AppColors.ucDavisBlue,
              fontFamily: 'Proxima Nova',
              fontSize: 11));
    } else {
      return Text(string,
          style: new TextStyle(
              color: AppColors.ucDavisBlue,
              fontFamily: 'Proxima Nova',
              fontSize: 11));
    }
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
