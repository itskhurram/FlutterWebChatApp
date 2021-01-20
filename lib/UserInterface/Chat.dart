import 'dart:async';
import 'package:myuwi/Repository/DatabaseHandler.dart';
import 'package:myuwi/UserInterface/AddCourse.dart';
import 'package:myuwi/UserInterface/AskQuestion.dart';
import 'package:myuwi/UserInterface/Home.dart';
import 'package:myuwi/UserInterface/MessageTitle.dart';
import 'package:myuwi/UserInterface/Signin.dart';
import 'package:myuwi/Values/AppValues.dart';
import 'package:myuwi/Widgets/AppSpaces.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class Chat extends StatefulWidget {
  //Chat({Key key}) : super(key: key);
  final String chatRoomId;
  Chat({this.chatRoomId});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  DatabaseHandler databaseHandler = new DatabaseHandler();
  String firstName = "";
  String lastName = "";
  String emailAddress = "";
  String myUserName = "";
  String ownerUserName = "";
  bool isOwner = false;
  Stream<QuerySnapshot> chats;
  ScrollController _controller = ScrollController();
  TextEditingController messageEditingController = new TextEditingController();
  FocusNode inputFieldNode;
  final assetsAudioPlayer = AssetsAudioPlayer();
  List<PopupMenuItem<dynamic>> notificationListChat =[];
  String notificationCountChat = "";
  addMessage() async {
    if (messageEditingController.text.isNotEmpty) {

       String tempMessage = messageEditingController.text;

  setState(() {
        messageEditingController.text = "";
      });

      Map<String, dynamic> chatMessageMap = {
        "sendBy": myUserName,
        "message": tempMessage,
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      if (ownerUserName == myUserName)
        isOwner = true;
      else
        isOwner = false;

      await databaseHandler.addMessageNotification(
          widget.chatRoomId,
          chatMessageMap,
          isOwner,
          ownerUserName + '@my.uwi.edu',
          tempMessage,
          myUserName + '@my.uwi.edu');
    }
  }

  @override
  void initState() {
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
    ownerUserName =
        widget.chatRoomId.substring(0, widget.chatRoomId.indexOf("_"));
    databaseHandler.getChats(widget.chatRoomId).then((val) {
      
          val.forEach((field) {
      setState(() {
        		SchedulerBinding.instance.addPostFrameCallback((_) {
            _controller.animateTo(
              _controller.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
      });
    });
    
      
      setState(() {
        chats = val;
       
        
      });
    });
    super.initState();
    inputFieldNode = FocusNode();
    getAllNotificationList();
  }

  getAllNotificationList() async {
    Stream<QuerySnapshot> notificationStream =
        await databaseHandler.getAllNotificationStreamChat(emailAddress);
    int previousCount = 0;

    notificationStream.forEach((field) {
      notificationListChat = [];
      
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
        notificationListChat.add(headerMenu);
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
        notificationListChat.add(menu);
      });
      setState(() {
        if (previousCount != int.parse(len.toString()) &&
            int.parse(len.toString()) > 0) {
          // assetsAudioPlayer.open(
          //   Audio("assets/audios/question.mp3"),
          //   autoStart: true,
          //   showNotification: true,
          // );
           assetsAudioPlayer
              .open(new Audio("assets/audios/question.mp3"))
              .then((value) {})
              .catchError((e) {});
        }
        notificationCountChat = len.toString();
        previousCount = int.parse(notificationCountChat);

        try {
          if (SystemChrome != null) {
            SystemChrome.setApplicationSwitcherDescription(
                new ApplicationSwitcherDescription(
              label: (notificationCountChat != "0" && notificationCountChat != "")
                  ? "(" + notificationCountChat + ") KarmaCollab App"
                  : "KarmaCollab App",
            )).then((value) {

            })
            .catchError((error) {
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
      } else if  (valueList[0] == "1") {
        sendMessageNotification(
            valueList[1], valueList[2], valueList[3], valueList[4]);
      } else {
        databaseHandler.removeNotificationChat(valueList[4]);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext ctx) => Home()));
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
                builder: (context) => Chat(
                      chatRoomId: chatRoomId,
                    )));
      }
    });
  }

  getChatRoomId(
      String questionOwnerUsername, String courseCode, String questionId) {
    return "$questionOwnerUsername\_$courseCode\_$questionId";
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

  @override
  void dispose() {
    inputFieldNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ucDavisBlue,
        iconTheme: new IconThemeData(color: AppColors.ucDavisWhite),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              databaseHandler.markAllMessageRead(widget.chatRoomId);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext ctx) => Home()));
            }),
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
          PopupMenuButton(
              onSelected: (value) {
                setState(() {
                  valuesSelected(value);
                });
              },
              tooltip: "Notification",
              icon: Badge(
                badgeColor: Colors.red,
                badgeContent: Text(notificationCountChat,
                    style: TextStyle(color: AppColors.ucDavisWhite)),
                showBadge: (notificationCountChat == "0" ||
                        notificationCountChat == "")
                    ? false
                    : true,
                child: Icon(Icons.notifications,
                    color: Colors.white, semanticLabel: 'Notifications'),
              ),
              itemBuilder: (BuildContext context) {
                return notificationListChat;
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
              //color: Colors.white,
              onPressed: () {
                html.window.sessionStorage['email'] = "";
                html.window.sessionStorage['firstName'] = "";
                html.window.sessionStorage['lastName'] = "";
                html.window.sessionStorage.clear();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (BuildContext ctx) => SignIn()));
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
      body: Column(
        children: <Widget>[
          Expanded(child: chatMessages()),
          messageBoxContainer(),
        ],
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                //scrollDirection: Axis.vertical,
                controller: _controller,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      message: snapshot.data.docs[index].data()["message"],
                      sender: snapshot.data.docs[index].data()["sendBy"],
                      sendByMe: myUserName ==
                          snapshot.data.docs[index].data()["sendBy"],
                      receiveTime: snapshot.data.docs[index].data()["time"]);
                })
            : Container();
      },
    );
  }

  Widget messageBoxContainer() {
    return Container(
      alignment: Alignment.bottomCenter,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(bottom: 0),
      // margin: EdgeInsets.fromLTRB(0, 500, 0, 0),
      //clipBehavior: Clip.hardEdge,
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24,
            0), //EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Row(
          children: [
            Expanded(
                child: TextFormField(
              enableSuggestions: true,
              controller: messageEditingController,
              style:
                  TextStyle(color: AppColors.white, fontSize: 16, height: 2.5),
              decoration: InputDecoration(
                hintText: "Message ...",
                hintStyle: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                    // borderRadius:
                    //     BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: AppColors.ucDavisBlue)),
                focusedBorder: OutlineInputBorder(
                    // borderRadius:
                    //     BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: AppColors.ucDavisBlue)),
                filled: true,
                fillColor: AppColors.ucDavisBlue,
                focusColor: AppColors.ucDavisBlue,
              ),
              focusNode: inputFieldNode,
              onFieldSubmitted: (value) {
                addMessage();
                FocusScope.of(context).requestFocus(inputFieldNode);
              },
            )),
            //SizedBox(width: 16,),
            GestureDetector(
              onTap: () {
                addMessage();
              },
              //Icon(Icons.send)
              child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          AppColors.ucDavisYellow,
                          AppColors.ucDavisYellow,
                        ],
                        begin: FractionalOffset.topLeft,
                        end: FractionalOffset.bottomRight),
                    //borderRadius: BorderRadius.circular(10)
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 24, vertical: 24), //EdgeInsets.all(12),

                  child: Icon(Icons.send)),
            ),
          ],
        ),
      ),
    );
  }
}
