import 'dart:async';
import 'package:myuwi/Repository/DatabaseHandler.dart';
import 'package:myuwi/UserInterface/MessageTitle.dart';
import 'package:myuwi/Values/AppValues.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/scheduler.dart';

class ChatPartial extends StatefulWidget {
  // ChatPartial({Key key}) : super(key: key);
  final String chatRoomId;
  ChatPartial({this.chatRoomId});

  @override
  _ChatPartialState createState() => _ChatPartialState();
}

class _ChatPartialState extends State<ChatPartial> {
  DatabaseHandler databaseHandler = new DatabaseHandler();
  String firstName = "";
  String lastName = "";
  String emailAddress = "";
  String myUserName = "";
  String ownerUserName = "";
  bool isOwner = false;
  Stream<QuerySnapshot> chatsPartial;
  ScrollController _controllerPartial = ScrollController();
  TextEditingController messageEditingController = new TextEditingController();
  FocusNode inputFieldNode;

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
    ownerUserName =
        widget.chatRoomId.substring(0, widget.chatRoomId.indexOf("_"));

    databaseHandler.getChats(widget.chatRoomId).then((val) {
      val.forEach((field) {
        setState(() {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _controllerPartial.animateTo(
              _controllerPartial.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        });
      });

      setState(() {
        chatsPartial = val;
      });
    });
    inputFieldNode = FocusNode();
  }

  // @override
  // void dispose() {
  //   inputFieldNode.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      stream: chatsPartial,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                //scrollDirection: Axis.vertical,
                controller: _controllerPartial,
                itemCount: snapshot.data.docs.length,
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
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24,0), 
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
                borderSide: BorderSide(color: AppColors.ucDavisBlue)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.ucDavisBlue)),
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
            GestureDetector(
              onTap: () {addMessage();},
              child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          AppColors.ucDavisYellow,
                          AppColors.ucDavisYellow,
                        ],
                        begin: FractionalOffset.topLeft,
                        end: FractionalOffset.bottomRight),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24), //EdgeInsets.all(12),
                  child: Icon(Icons.send)),
            ),
          ],
        ),
      ),
    );
  }
}
