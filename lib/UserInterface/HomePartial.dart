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

class HomePartial extends StatefulWidget {
  //HomePartial({Key key}) : super(key: key);
  final String questionId;
  HomePartial({this.questionId});

  @override
  _HomePartialState createState() => _HomePartialState();
}

class _HomePartialState extends State<HomePartial> {
  DatabaseHandler databaseHandler = new DatabaseHandler();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String firstName = "",
      lastName = "",
      emailAddress = "",
      courseCode = "",
      myUserName = "",
      notificationCount = "",
      studentDocumentId;
  int numberOfUniquePeopleCall = 0, millisecondsSpent = 0;
  bool _isLoading;
  List<PopupMenuItem<dynamic>> notificationList =[];
  List<DocumentSnapshot> _questionList = [];
StreamController _questionStreamController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: getStreamBody(),
    );
  }

  @override
  void initState() {
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
     _questionStreamController = StreamController.broadcast();
    getStreamQueryData();
  }

  @override
  void dispose() {
    super.dispose();
    _questionStreamController?.close();
    _questionStreamController = null;
  }
  getStreamBody() {
    return Container(
      child: StreamBuilder(
        stream: _questionStreamController.stream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    if ((snapshot.data.docs[index].data()['activityStarted'] ==
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
                            color:snapshot.data.docs[index].id == widget.questionId
                          ? Colors.orange
                          : Colors.white,
                            child: ListTile(
                              leading: Container(
                                child: Icon(
                                  Icons.account_circle,
                                  color: AppColors.ucDavisBlue,
                                ),
                              ),
                              title: Text(
                                "(" +
                                    snapshot.data.docs[index]
                                        .data()['courseCode'] +
                                    ") " +
                                    snapshot.data.docs[index]
                                        .data()['question'],
                                style: TextStyle(
                                    fontWeight: ((snapshot.data.docs[index]
                                                            .data()[
                                                        'hasChatMessagesFromOwner'] ==
                                                    "true" &&
                                                snapshot.data.docs[index]
                                                        .data()['email'] !=
                                                    emailAddress) ||
                                            (snapshot.data.docs[index].data()[
                                                        'hasChatMessagesForOwner'] ==
                                                    "true" &&
                                                snapshot.data.docs[index]
                                                        .data()['email'] ==
                                                    emailAddress))
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                              ),
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
                                          databaseHandler.markQuestionResolved(
                                              "Question",
                                              snapshot.data.docs[index].id);
                                        },
                                      )),
                                  Visibility(
                                    visible: getIconVisibility(
                                        snapshot.data.docs[index]),
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
                                      child: (snapshot.data.docs[index].data()[
                                                      'ownerMessageCounter'] !=
                                                  null &&
                                              snapshot.data.docs[index]
                                                      .data()[
                                                          'ownerMessageCounter']
                                                      .toString()
                                                      .toLowerCase() !=
                                                  "0")
                                          ? Badge(
                                              badgeColor: AppColors.ucDavisBlue,
                                              badgeContent: Text(
                                                  snapshot.data.docs[index]
                                                      .data()[
                                                          'ownerMessageCounter']
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .ucDavisWhite)),
                                              child: IconButton(
                                                color: snapshot.data.docs[index]
                                                                .data()[
                                                            'hasChatMessagesForOwner'] ==
                                                        "true"
                                                    ? AppColors.ucDavisGreen
                                                    : AppColors.ucDavisBlue,
                                                icon: Icon(Icons.chat),
                                                onPressed: () {
                                                  sendMessage(
                                                      snapshot.data.docs[index]
                                                          .data()['email'],
                                                      snapshot.data.docs[index]
                                                          .data()['courseCode'],
                                                      snapshot
                                                          .data.docs[index].id);
                                                },
                                              ),
                                            )
                                          : IconButton(
                                              color: snapshot.data.docs[index]
                                                              .data()[
                                                          'hasChatMessagesForOwner'] ==
                                                      "true"
                                                  ? AppColors.ucDavisGreen
                                                  : AppColors.ucDavisBlue,
                                              icon: Icon(Icons.chat),
                                              onPressed: () {
                                                sendMessage(
                                                    snapshot.data.docs[index]
                                                        .data()['email'],
                                                    snapshot.data.docs[index]
                                                        .data()['courseCode'],
                                                    snapshot
                                                        .data.docs[index].id);
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
                                              color: snapshot.data.docs[index]
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
                                                snapshot.data.docs[index].id);
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
                                              
                                            var ownerStudentId = '';
                                            var helperStudentid = '';

                                         if (isOwner) {
                                            ownerStudentId = studentDocumentId;
                                          } else {
                                            helperStudentid = studentDocumentId;
                                          }

                                          js.context.callMethod('joinCall', [
                                            snapshot.data.docs[index].id,
                                            snapshot.data.docs[index]
                                                .data()['email']
                                                .toString()
                                                .toLowerCase(),
                                            firstName,
                                            lastName,
                                            emailAddress,
                                            isOwner,
                                             ownerStudentId,
                                       snapshot.data.docs[index].data()['courseCode'],
                                            helperStudentid
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
    );
  }


  getBody() {
    return Container(
      child: new ListView.builder(
          itemCount: _questionList.length + 1,
          itemBuilder: (_, int index) {
            if (index < _questionList.length) {
              final DocumentSnapshot document = _questionList[index];
              if ((document.data()['activityStarted'] == false) &&
                  ((int.parse(document.data()['createdDate'].toString()) +
                          (3 * 86400000)) <
                      (DateTime.now().millisecondsSinceEpoch))) {
                return Container();
              } else {
                return Container(
                  child: Card(
                      color: document.id == widget.questionId
                          ? Colors.orange
                          : Colors.white,
                      child: ListTile(
                        leading: Container(
                          child: Icon(
                            Icons.account_circle,
                            color: AppColors.ucDavisBlue,
                          ),
                        ),
                        title: Text(
                          "(" +
                              document.data()['courseCode'] +
                              ") " +
                              document.data()['question'],
                          style: TextStyle(
                              fontWeight: ((document.data()[
                                                  'hasChatMessagesFromOwner'] ==
                                              "true" &&
                                          document.data()['email'] !=
                                              emailAddress) ||
                                      (document.data()[
                                                  'hasChatMessagesForOwner'] ==
                                              "true" &&
                                          document.data()['email'] ==
                                              emailAddress))
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Visibility(
                                visible: (document
                                        .data()['email']
                                        .toString()
                                        .toLowerCase() ==
                                    emailAddress.toLowerCase()),
                                child: IconButton(
                                  color: AppColors.ucDavisGreen,
                                  icon: Icon(Icons.verified_user),
                                  tooltip: "Mark Resolved",
                                  onPressed: () {
                                    databaseHandler.markQuestionResolved(
                                        "Question", document.id);
                                     getStreamQueryData();
                                  },
                                )),
                            Visibility(
                              visible: getIconVisibility(document),
                              child: Icon(
                                Icons.star,
                                color: AppColors.ucDavisYellow,
                              ),
                            ),
                            Visibility(
                                visible: (document
                                        .data()['email']
                                        .toString()
                                        .toLowerCase() ==
                                    emailAddress.toLowerCase()),
                                child: (document.data()[
                                                'ownerMessageCounter'] !=
                                            null &&
                                        document
                                                .data()['ownerMessageCounter']
                                                .toString()
                                                .toLowerCase() !=
                                            "0")
                                    ? Badge(
                                        badgeColor: AppColors.ucDavisBlue,
                                        badgeContent: Text(
                                            document
                                                .data()['ownerMessageCounter']
                                                .toString(),
                                            style: TextStyle(
                                                color: AppColors.ucDavisWhite)),
                                        child: IconButton(
                                          color: document.data()[
                                                      'hasChatMessagesForOwner'] ==
                                                  "true"
                                              ? AppColors.ucDavisGreen
                                              : AppColors.ucDavisBlue,
                                          icon: Icon(Icons.chat),
                                          onPressed: () {
                                            sendMessage(
                                                document.data()['email'],
                                                document.data()['courseCode'],
                                                document.id);
                                          },
                                        ),
                                      )
                                    : IconButton(
                                        color: document.data()[
                                                    'hasChatMessagesForOwner'] ==
                                                "true"
                                            ? AppColors.ucDavisGreen
                                            : AppColors.ucDavisBlue,
                                        icon: Icon(Icons.chat),
                                        onPressed: () {
                                          sendMessage(
                                              document.data()['email'],
                                              document.data()['courseCode'],
                                              document.id);
                                        },
                                      )),
                            Visibility(
                                visible: document
                                        .data()['email']
                                        .toString()
                                        .toLowerCase() !=
                                    emailAddress.toLowerCase(),
                                child: IconButton(
                                    icon: Icon(Icons.chat,
                                        color: document.data()[
                                                    'hasChatMessagesFromOwner'] ==
                                                "true"
                                            ? AppColors.ucDavisGreen
                                            : AppColors.ucDavisBlue),
                                    color: AppColors.ucDavisBlue,
                                    onPressed: () {
                                      sendMessage(
                                          document.data()['email'],
                                          document.data()['courseCode'],
                                          document.id);
                                    })),
                            Container(
                              child: IconButton(
                                  icon: Icon(Icons.video_call,
                                      color: AppColors.ucDavisBlue),
                                  onPressed: () {
                                    var isOwner = document
                                            .data()['email']
                                            .toString()
                                            .toLowerCase() ==
                                        emailAddress.toLowerCase();


                                    js.context.callMethod('joinCall', [
                                      document.id,
                                      document
                                          .data()['email']
                                          .toString()
                                          .toLowerCase(),
                                      firstName,
                                      lastName,
                                      emailAddress,
                                      isOwner,
                                      document.data()['courseCode']
                                    ]);
                                  }),
                            )
                          ],
                        ),
                      )),
                );
              }
            } else {
              return Center(
                child: new Opacity(
                  opacity: _isLoading ? 1.0 : 0.0,
                  child: new SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: new CircularProgressIndicator()),
                ),
              );
            }
          }),
    );
  }

  void sendMessage(
      String questionOwneremail, String courseCode, String questionId) {
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

  Future<Null> getStreamQueryData() async {
    // _isLoading = true;
    // var questionStream = await databaseHandler
    //     .getQuestionListbyCourseCodePageStreamList("Question", emailAddress);
    // List<DocumentSnapshot> _localData = new List<DocumentSnapshot>();
    //  _questionList = new List<DocumentSnapshot>();
    // questionStream.forEach((field) {
    //   if (field.docs.length > 0) {
    //     field.docs.asMap().forEach((index, data) {
    //       if (!elementExist(_localData, field.docs[index]))
    //         _localData.add(field.docs[index]);
    //     });
    //     setState(() {
    //       _questionList = _localData;
    //        _questionList.sort((a, b) =>
    //           b.data()['createdDate'].compareTo(a.data()['createdDate']));
    //       _isLoading = false;
    //     });
    //   }
    // });
      _isLoading = true;
    var questionStream = await databaseHandler
        .getQuestionListbyCourseCodePageStreamList("Question", emailAddress);
        _questionStreamController.sink.addStream(questionStream);
    _isLoading = false;
  }

  bool elementExist(
      List<DocumentSnapshot> _localData, DocumentSnapshot document) {
    bool found = false;
    for (var item in _localData) {
      if (item.id == document.id) {
        found = true;
        break;
      }
    }
    return found;
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

  bool getIconVisibility(doc) {
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

  String getChatRoomId(
      String questionOwnerUsername, String courseCode, String questionId) {
    return "$questionOwnerUsername\_$courseCode\_$questionId";
  }
}
