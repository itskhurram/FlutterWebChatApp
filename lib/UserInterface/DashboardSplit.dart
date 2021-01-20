import 'package:myuwi/Repository/DatabaseHandler.dart';
import 'package:myuwi/UserInterface/AddCourse.dart';
import 'package:myuwi/UserInterface/AskQuestion.dart';
import 'package:myuwi/UserInterface/ChatPartial.dart';
import 'package:myuwi/UserInterface/Home.dart';
import 'package:myuwi/UserInterface/HomePartial.dart';
import 'package:myuwi/UserInterface/Signin.dart';
import 'package:myuwi/UserInterface/SplitWidget.dart';
import 'package:myuwi/Values/AppValues.dart';
import 'package:myuwi/Widgets/AppSpaces.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:linkable/linkable.dart';

class DashboardSplit extends StatefulWidget {
  //DashboardSplit({Key key}) : super(key: key);
  final String chatRoomId;
  DashboardSplit({this.chatRoomId});
  @override
  _DashboardSplitState createState() => _DashboardSplitState();
}

class _DashboardSplitState extends State<DashboardSplit> {
  DatabaseHandler databaseHandler = new DatabaseHandler();
  String firstName = "", lastName = "", emailAddress = "",courseCode = "", myUserName = "",dropdownValue = 'All',questionId = "",notificationCount = "",studentDocumentId = "";
  //ScrollController controller;
  bool _isLoading;
  int numberOfUniquePeopleCall = 0, millisecondsSpent = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final assetsAudioPlayer = new AssetsAudioPlayer();
  List<PopupMenuItem<dynamic>> notificationList =[];
        List<DocumentSnapshot> _participatedStudentList =[];
  final GlobalKey myglobalkey = GlobalKey();
  List<String> _courseListData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: AppColors.ucDavisBlue,
          iconTheme: new IconThemeData(color: AppColors.ucDavisWhite),
          leading: IconButton(
              icon: Icon(Icons.menu),
              color: Colors.white,
              onPressed: handleDrawer),
          actions: <Widget>[
             IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                tooltip: "Back to Dashboard",
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext ctx) => Home()));
                }),
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
        body: Container(
            child: SplitWidget(
          key: myglobalkey,
          childFirst: Container(
            child: HomePartial(questionId: questionId),
          ),
          childSecond: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height - 160.0,
                child: ChatPartial(chatRoomId: widget.chatRoomId),
              )
            ],
          ),
        )),
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

                        
          Card(
            child: ListTile(
              tileColor: AppColors.ucDavisYellow,
              title: Text('Top Performing Students'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.only(
                  left: 12.0, right: 12.0, top: 12.0, bottom: 12.0),
              child: Container(
                child: DropdownButtonFormField<String>(
                  hint: Text("Select course"),
                  value: dropdownValue,
                  validator: (value) => value == null || value == ""
                      ? 'Please select in your course'
                      : null,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: AppColors.ucDavisBlue),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                      courseCode = newValue;
                      getParticipationStreamList(newValue);
                    });
                  },
                  items: _courseListData
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Container(
            height: double.maxFinite,
            child: ListView.builder(
                itemCount: _participatedStudentList.length + 1,
                itemBuilder: (_, int studentindex) {
                  if (studentindex < _participatedStudentList.length) {
                    final DocumentSnapshot document =
                        _participatedStudentList[studentindex];
                    return Container(
                      child: Card(
                          //color:
                          child: ListTile(
                              leading: Text(document.data()['lastName']+', '+ document.data()['firstName']),
                              //title: Text("(" + document.data()['courseCode'] + ") "),
                              trailing: Container(
                                child: Text(printDuration(document.data()['milliSecondsSpent'])),
                              ))),
                    );
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
          )
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
    
    super.dispose();
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
    questionId = widget.chatRoomId.substring(
        widget.chatRoomId.lastIndexOf("_") + 1, widget.chatRoomId.length);
    _isLoading = true;
    getcourseListData();
    getParticipationStreamList("All");
    getAllNotificationList();
    getLeftMenuItems();
   
  }
  handleDrawer() {
    setState(() {
       getParticipationStreamList("All");
      scaffoldKey.currentState.openDrawer();
    });
  }
  Future<Null> getcourseListData() async {
    if (html.window.sessionStorage != null &&
        html.window.sessionStorage['email'] != null) {
      emailAddress = html.window.sessionStorage['email'];
    }
    QuerySnapshot coursedata =
        await databaseHandler.getCourseByStudent("Student", emailAddress);
    if (coursedata != null && coursedata.docs.length > 0) {
      setState(() {
        for (var i = 0; i < coursedata.docs.length; i++) {
          //documentId = coursedata.documents[i].documentID;
          var myDocument = coursedata.docs[i].data()["CourseList"];
          //print(myDocument);
          if (myDocument != null) {
            for (var item in myDocument) {
              _courseListData.add(item.toString());
            }
          } else {
            _courseListData.add(coursedata.docs[i].data()["courseCode"]);
          }

          break;
        }
      });
    }
    _courseListData.remove("");
    _courseListData.add("All");
    if (_courseListData.length == 1 && _courseListData[0] == null) {
      _courseListData = [];
      _courseListData.add("All");
    }

    return null;
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
            )).then((value) {}).catchError((error) {
              //print(error);
            });
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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardSplit(
                      chatRoomId: widget.chatRoomId,
                    )));
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
         _isLoading = false;
      });
    });   
  }
    getParticipationStreamList(String ddlValue) async {
    var studentParticipationStream =
        await databaseHandler.getLeftMenuItemsStudentParticipationStreamList(
            emailAddress.toLowerCase());
    List<DocumentSnapshot> _localStudentData = [];
    _participatedStudentList = [];
    studentParticipationStream.forEach((field) {
      if (field.docs.length > 0) {
        field.docs.asMap().forEach((index, data) {
          if (ddlValue == 'All') {
            if (!elementExist(_localStudentData, field.docs[index])) {
              _localStudentData.add(field.docs[index]);
            }
          } else {
            if (!elementExist(_localStudentData, field.docs[index]) &&
                field.docs[index].data()['courseCode'] == ddlValue) {
              _localStudentData.add(field.docs[index]);
            }
          }
        });
        setState(() {
          _participatedStudentList = _localStudentData;
          _participatedStudentList.sort((a, b) => b
              .data()['milliSecondsSpent']
              .compareTo(a.data()['milliSecondsSpent']));
          _isLoading = false;
        });
      }
      else
      {
          _isLoading = false;
      }
    });
  }
  String printDuration(int miliSeconds) {
    Duration duration = new Duration(milliseconds: miliSeconds);
    
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
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

  // void _scrollListener() {
  //   if (!_isLoading) {
  //     if (controller.position.pixels == controller.position.maxScrollExtent) {
  //       setState(() => _isLoading = true);
  //       getLeftMenuItems();
  //     }
  //   }
  // }

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

    databaseHandler.getStudentsbyCourse(courseCode).then((val) async {
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
        await databaseHandler
            .addChatRoom(
                chatRoom, chatRoomId, myUserName == questionOwnerUsername)
            .then((val) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardSplit(
                        chatRoomId: chatRoomId,
                      )));
        });
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
}
