import 'package:myuwi/Models/NotificationLog.dart';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:http/browser_client.dart';
//import 'dart:convert';

class DatabaseHandler {
  final dbHandler = FirebaseFirestore.instance;
  Future<String> saveQuestion(String collectionName, String question,
      String email, String courseCode) async {
    courseCode = courseCode.trim().toUpperCase();
    email = email.trim().toLowerCase();
    question = question.trim();
    DocumentReference ref;
    await dbHandler.collection(collectionName).add({
      'question': '$question',
      'email': '$email',
      'courseCode': '$courseCode',
      'status': 'Pending',
      'activityStarted': false,
      'createdDate': DateTime.now().millisecondsSinceEpoch
    }).then((questionDocument) async {
      ref = questionDocument;

      //Read All Students of This Course
      await dbHandler
          .collection("Student")
          .where('CourseList', arrayContains: courseCode)
          .get()
          .then((studentList) async {
        if (studentList != null && studentList.docs.length > 0) {
          for (var studentDoc in studentList.docs) {
            if (studentDoc.data()['email'].toString().trim().toLowerCase() !=
                email) {
              await dbHandler.collection("Notification").add({
                'questionId': questionDocument.id,
                'toEmail': studentDoc.data()['email'],
                'fromEmail': email,
                'courseCode': '$courseCode',
                'createdDate': DateTime.now().millisecondsSinceEpoch,
                'clientToken': studentDoc.data()['clientToken'],
                'notificationTitle': 'New Question',
                'notificationContent': '$question',
                'isRead': false,
                'type': NotificationType
                    .Question //Notification Type 0 = Question 1=Chat
              }).then((questionNotification) async {
                // final client = BrowserClient();
                // String serverKey =
                //     'AAAA6IVnr9A:APA91bH2beI5XuM242wy7J_zxrw3PTJCiHESGw7bUuC1boTuXp0C-MdzIjlMZxbrGE2yzPORV3sHIOmWY_dGcTTCQtjaCEoi1FFUq_3SbTA2K333l__OfqbY6O3HSK2bSZRhAMXqxLGQ';
                // await client.post('https://fcm.googleapis.com/fcm/send',
                //     headers: {
                //       'Content-Type': 'application/json',
                //       'Authorization': 'key=$serverKey',
                //     },
                //     body: jsonEncode({
                //       'notification': {
                //         'title': 'New Question',
                //         'body': '$question',
                //       },
                //       'data': {
                //         'Current time': DateTime.now().toIso8601String(),
                //         'Current User': email,
                //         'Message Body': '$question'
                //       },
                //       'to': studentDoc.data()['clientToken']
                //     }));
              });
            }
          }
        }
      });
    });
    return ref.id;
  }

  Future<String> saveCourseList(
      String collectionName, List<String> courseList, String documentId) async {
    if (documentId != "" && documentId != "null") {
      await dbHandler
          .collection(collectionName)
          .doc(documentId)
          .update({'CourseList': courseList});
      return documentId;
    } else {
      return null;
    }
  }

  signUp(String collectionName, String firstname, String lastname, String email,
      String password) async {
    String dcoumentId;
    //Check if exist in Admin
    await dbHandler
        .collection('Administrators')
        .where("email", isEqualTo: '$email')
        .get()
        .then((value) async {
      if (value != null && value.docs.length > 0) {
        return dcoumentId;
      } else {
        email = email.trim().toLowerCase();

        return await dbHandler.collection(collectionName).add({
          'firstName': '$firstname',
          'lastName': '$lastname',
          'email': '$email',
          'password': '$password',
          'totalLoggedInTime': 0,
          'totalHelpedSpentMilliSeconds': 0
        });
      }
    });
  }

  signIn(String collectionName, String email, String password) async {
    email = email.trim().toLowerCase();
    return await dbHandler
        .collection('Administrators')
        .where("email", isEqualTo: '$email')
        .where("password", isEqualTo: '$password')
        .get()
        .then((value) async {
      if (value != null && value.docs.length > 0) {
        return value;
      } else {
        return await dbHandler
            .collection(collectionName)
            .where("email", isEqualTo: '$email')
            .where("password", isEqualTo: '$password')
            .get();
      }
    });
  }

  updatelogoutTime(documentId, int loginInTime, int totalLoggedInTime) {
    // int value = totalLoggedInTime +
    //     (DateTime.now().millisecondsSinceEpoch -
    //         int.parse(loginInTime.toString()));
    dbHandler.collection('Student').doc(documentId).update({
      'totalLoggedInTime': totalLoggedInTime +
          (DateTime.now().millisecondsSinceEpoch -
              int.parse(loginInTime.toString()))
    });
  }

  updatelogoutTimeAdmin(documentId, int loginInTime, int totalLoggedInTime) {
    dbHandler.collection('Administrators').doc(documentId).update({
      'totalLoggedInTime': totalLoggedInTime +
          (DateTime.now().millisecondsSinceEpoch -
              int.parse(loginInTime.toString()))
    });
  }

  Future<String> usernameExist(String collectionName, String email) async {
    String refdocumentID = "";
    email = email.trim().toLowerCase();
    await dbHandler
        .collection(collectionName)
        .where("email", isEqualTo: '$email')
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        if (value.docs[i].data()['email'].toString().trim().toLowerCase() !=
                "" &&
            value.docs[i].data()['email'].toString().trim().toLowerCase() ==
                email.trim().toLowerCase()) {
          refdocumentID = value.docs[i].data()['email'];
          break;
        }
      }
    });
    return refdocumentID;
  }

  checkExistanceNsignUP(String collectionName, String firstname,
      String lastname, String email, String password) async {
    //String refdocumentID = "";
    email = email.trim().toLowerCase();
    final QuerySnapshot studentresult = await dbHandler
        .collection(collectionName)
        .where("email", isEqualTo: '$email')
        .get();
    final QuerySnapshot adminresult = await dbHandler
        .collection("Administrators")
        .where("email", isEqualTo: '$email')
        .get();
    if (studentresult.docs.length == 0 && adminresult.docs.length == 0) {
      email = email.trim().toLowerCase();

      return await dbHandler.collection(collectionName).add({
        'firstName': '$firstname',
        'lastName': '$lastname',
        'email': '$email',
        'password': '$password',
        'totalLoggedInTime': 0,
        'totalHelpedSpentMilliSeconds': 0
      });
    } else {
      return null;
    }
  }

  Future<QuerySnapshot> getQuestionListbyCourseCodePage(String collectionName,
      String emailAddress, int pageSize, DocumentSnapshot lastVisible) async {
    var querySnapshot;
    QuerySnapshot coursedata =
        await getCourseByStudent("Student", emailAddress);
    if (coursedata != null && coursedata.docs.length > 0) {
      var courseArrayList = coursedata.docs[0].data()["CourseList"];
      if (courseArrayList != null) {
        if (lastVisible == null) {
          querySnapshot = await dbHandler
              .collection(collectionName)
              .orderBy('createdDate', descending: true)
              .limit(pageSize)
              .where("courseCode", whereIn: courseArrayList)
              .get();
        } else {
          querySnapshot = await dbHandler
              .collection(collectionName)
              .orderBy('createdDate', descending: true)
              .startAfter([lastVisible.data()['createdDate']])
              .limit(pageSize)
              .where("courseCode", whereIn: courseArrayList)
              .get();
        }
      } else {
        return querySnapshot;
      }
    }
    return querySnapshot;
  }

  markQuestionResolved(String collectionName, String documentId) {
    dbHandler.collection(collectionName).doc(documentId).update({
      'status': "Resolved",
      'statusDate': DateTime.now().millisecondsSinceEpoch
    });
  }

  getQuestionListbyCourseCodePageStream(
      String collectionName, String emailAddress) async {
    QuerySnapshot coursedata =
        await getCourseByStudent("Student", emailAddress);

    if (coursedata != null && coursedata.docs.length > 0) {
      var courseArrayList = coursedata.docs[0].data()["CourseList"];
      if (courseArrayList != null) {
        return dbHandler
            .collection(collectionName)
            .orderBy('createdDate', descending: true)
            .where("courseCode", whereIn: courseArrayList)
            .where("status", isEqualTo: 'Pending')
            .snapshots();
      } else {
        return null;
      }
    }

   
    return null;
  }

  getQuestionListbyCourseCodePageStreamList(
      String collectionName, String emailAddress) async {
    QuerySnapshot coursedata =
        await getCourseByStudent("Student", emailAddress);
    Stream<QuerySnapshot> streamQuerySnapshot;
    if (coursedata != null && coursedata.docs.length > 0) {
      var courseArrayList = coursedata.docs[0].data()["CourseList"];
      if (courseArrayList != null) {
        if (courseArrayList.length <= 10) {
          streamQuerySnapshot = dbHandler
              .collection(collectionName)
              .orderBy('createdDate', descending: true)
              .where("courseCode", whereIn: courseArrayList)
              .where("status", isEqualTo: 'Pending')
              .snapshots();

          return streamQuerySnapshot;
        } else {
          var tenItemArrayList = [];
          for (int k = 0; k < courseArrayList.length; k += 10) {
            tenItemArrayList.add(courseArrayList.sublist(
                k,
                k + 10 > courseArrayList.length
                    ? courseArrayList.length
                    : k + 10));
          }

          var group = StreamGroup<QuerySnapshot>();
          for (var tenitemArray in tenItemArrayList) {
            group.add(dbHandler
                .collection(collectionName)
                .orderBy('createdDate', descending: true)
                .where("courseCode", whereIn: tenitemArray)
                .where("status", isEqualTo: 'Pending')
                .snapshots());
            // streamList.add(dbHandler
            //     .collection(collectionName)
            //     .orderBy('createdDate', descending: true)
            //     .where("courseCode", whereIn: tenitemArray)
            //     .where("status", isEqualTo: 'Pending')
            //     .snapshots());

            // sg.add(dbHandler
            //     .collection(collectionName)
            //     .orderBy('createdDate', descending: true)
            //     .where("courseCode", whereIn: tenitemArray)
            //     .where("status", isEqualTo: 'Pending')
            //     .snapshots());
            // break;
          }
          //streamList.forEach(group.add);
          group.close();
          streamQuerySnapshot = group.stream;

          // sg.close();
          //streamQuerySnapshot = StreamGroup.mergeBroadcast(streams)(streamList);
          //streamQuerySnapshot = sg.stream;

          //return streamGroup;
          return streamQuerySnapshot;
        }
      } else {
        return streamQuerySnapshot;
      }
    }
    return streamQuerySnapshot;
  }

  Stream<QuerySnapshot> mergeStreams<QuerySnapshot>(
      Stream<Stream<QuerySnapshot>> source) {
    var sg = StreamGroup<QuerySnapshot>();
    source.forEach(sg.add).whenComplete(sg.close);
    // This doesn't handle errors in [source].
    // Maybe insert
    //   .catchError((e, s) {
    //      sg.add(Future<T>.error(e, s).asStream())
    // before `.whenComplete` if you worry about errors in [source].
    return sg.stream;
  }

  Future<QuerySnapshot> getLeftMenuItemsTime(String userName) async {
    return await dbHandler
        .collection("VideoChatRoom")
        .where("toUser", isEqualTo: '$userName')
        .get();
  }

  getLeftMenuItemsTimeStream(String userName) async {
    return dbHandler
        .collection("VideoChatRoom")
        .where("toUser", isEqualTo: '$userName')
        .snapshots();
  }

  getLeftMenuItemsStudentParticipationStreamList(String emailAddress) async {
    QuerySnapshot coursedata =
        await getCourseByStudent("Student", emailAddress);
    Stream<QuerySnapshot> streamQuerySnapshot;
    List<Stream<QuerySnapshot>> streamList = [];
    if (coursedata != null && coursedata.docs.length > 0) {
      var courseArrayList = coursedata.docs[0].data()["CourseList"];
      courseArrayList.remove("");
      if (courseArrayList != null) {
        if (courseArrayList.length <= 10) {
          streamQuerySnapshot = dbHandler
              .collection("StudentParticipation")
              .where("courseCode", whereIn: courseArrayList)
              .snapshots();
        } else {
          var tenItemArrayList = [];
          for (int k = 0; k < courseArrayList.length; k += 10) {
            tenItemArrayList.add(courseArrayList.sublist(
                k,
                k + 10 > courseArrayList.length
                    ? courseArrayList.length
                    : k + 10));
          }

          var group = StreamGroup<QuerySnapshot>();
          for (var tenitemArray in tenItemArrayList) {
            streamList.add(dbHandler
                .collection("StudentParticipation")
                .where("courseCode", whereIn: tenitemArray)
                .snapshots());
          }
          streamList.forEach(group.add);
          group.close();
          streamQuerySnapshot = group.stream;
        }
        return streamQuerySnapshot;
      } else {
        return streamQuerySnapshot;
      }
    }
    return streamQuerySnapshot;
  }

  Future<QuerySnapshot> searchChatRoomsByQuestionId(String collectionName,
      String questionId, int pageSize, DocumentSnapshot lastVisible) async {
    var querySnapshot;
    if (lastVisible == null) {
      querySnapshot = await dbHandler
          .collection(collectionName)
          .orderBy('createdDate', descending: false)
          .limit(pageSize)
          .where("questionId", isEqualTo: questionId)
          .get();
    } else {
      querySnapshot = await dbHandler
          .collection(collectionName)
          .orderBy('createdDate', descending: false)
          .startAfter([lastVisible.data()['createdDate']])
          .limit(pageSize)
          .where("courseCode", isEqualTo: questionId)
          .get();
    }
    return querySnapshot;
  }

  Future<QuerySnapshot> getCourseByStudent(
      String collectionName, String email) async {
    email = email.trim().toLowerCase();
    var querySnapshot;

    querySnapshot = await dbHandler
        .collection(collectionName)
        .where("email", isEqualTo: '$email')
        .get();
    return querySnapshot;
  }

  getDocumentById(String collectionName, String documentID) async {
    return await dbHandler.collection(collectionName).doc(documentID).get();
  }

  addChatRoom(chatRoom, chatRoomId, isOwner) async {
    await dbHandler
        .collection("ChatRoom")
        .doc(chatRoomId)
        .set(chatRoom)
        .catchError((e) {
      print(e);
    });
    if (isOwner) {
      String documentID = chatRoomId.substring(
          chatRoomId.lastIndexOf("_") + 1, chatRoomId.length);
      await dbHandler.collection('Question').doc(documentID).update({
        'ownerMessageCounter': 0,
        //'hasChatMessagesFromOwner': "false",
        'hasChatMessagesForOwner': "false",
        'activityStarted': true,
      });
    } else {
      String documentID = chatRoomId.substring(
          chatRoomId.lastIndexOf("_") + 1, chatRoomId.length);
      await dbHandler.collection('Question').doc(documentID).update({
        'hasChatMessagesFromOwner': "false",
        'activityStarted': true,
        //'hasChatMessagesForOwner': "false"
      });
    }
  }

  markAllMessageRead(chatRoomId) async {
    String documentID = chatRoomId.substring(
        chatRoomId.lastIndexOf("_") + 1, chatRoomId.length);
    await dbHandler
        .collection('Question')
        .doc(documentID)
        .update({'ownerMessageCounter': 0, 'hasChatMessagesForOwner': "false"});
  }

  getChats(String chatRoomId) async {
    return dbHandler
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("Chats")
        .orderBy('time')
        .snapshots();
  }

  addMessage(String chatRoomId, chatMessageData, isOwner) {
    dbHandler
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("Chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
    if (isOwner) {
      String documentID = chatRoomId.substring(
          chatRoomId.lastIndexOf("_") + 1, chatRoomId.length);
      dbHandler.collection('Question').doc(documentID).update({
        'hasChatMessagesFromOwner': "true",
        'hasChatMessagesForOwner': "false",
        'activityStarted': true,
      });
    } else {
      String documentID = chatRoomId.substring(
          chatRoomId.lastIndexOf("_") + 1, chatRoomId.length);
      dbHandler.collection('Question').doc(documentID).update({
        'hasChatMessagesFromOwner': "false",
        'hasChatMessagesForOwner': "true",
        'chatStarted': "true",
        'activityStarted': true,
        'ownerMessageCounter': FieldValue.increment(1),
        //'participatedEmail': FieldValue.arrayUnion([fromUserEmail])
      });
    }
  }

  addMessageNotification(String chatRoomId, chatMessageData, isOwner,
      ownerEmail, messageText, fromUserEmail) async {
    await dbHandler
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("Chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
    if (isOwner) {
      String documentID = chatRoomId.substring(
          chatRoomId.lastIndexOf("_") + 1, chatRoomId.length);
      dbHandler.collection('Question').doc(documentID).update({
        'hasChatMessagesFromOwner': "true",
        'hasChatMessagesForOwner': "false",
        'activityStarted': true,
      });
    } else {
      String documentID = chatRoomId.substring(
          chatRoomId.lastIndexOf("_") + 1, chatRoomId.length);

      String courseCode = chatRoomId.substring(
          chatRoomId.indexOf("_") + 1, chatRoomId.lastIndexOf("_"));

      await dbHandler.collection('Question').doc(documentID).update({
        'hasChatMessagesFromOwner': "false",
        'hasChatMessagesForOwner': "true",
        'chatStarted': "true",
        'activityStarted': true,
        'ownerMessageCounter': FieldValue.increment(1),
        'participatedEmail': FieldValue.arrayUnion([fromUserEmail])
      }).then((value) async {
        await dbHandler.collection("Notification").add({
          'questionId': documentID,
          'toEmail': ownerEmail,
          'fromEmail': fromUserEmail,
          'courseCode': '$courseCode',
          'createdDate': DateTime.now().millisecondsSinceEpoch,
          'clientToken': null,
          'notificationTitle': 'New Message',
          'notificationContent': '$messageText',
          'isRead': false,
          'type': NotificationType
              .ChatMessage //Notification Type 0 = Question 1=Chat
        }).then((questionNotification) async {});
      });
    }
  }

  getUserChats(String itIsMyName) async {
    return dbHandler
        .collection("ChatRoom")
        .where('userList', arrayContains: itIsMyName)
        .snapshots();
  }

  getStudentsbyCourse(String courseCode) async {
    return await dbHandler
        .collection("Student")
        .where('CourseList', arrayContains: courseCode)
        .get();
  }

  getAllStudents() async {
    return await dbHandler.collection("Student").get();
  }

  getAllQuestions(int fromDateTicks, int toDateTicks) async {
    return await dbHandler
        .collection("Question")
        .where('createdDate', isGreaterThanOrEqualTo: fromDateTicks)
        .where('createdDate', isLessThanOrEqualTo: toDateTicks)
        .get();
  }

  getAllQuestionsByStudent(
      int fromDateTicks, int toDateTicks, String email) async {
    return await dbHandler
        .collection("Question")
        .where('email', isEqualTo: email.trim().toLowerCase())
        .where('createdDate', isGreaterThanOrEqualTo: fromDateTicks)
        .where('createdDate', isLessThanOrEqualTo: toDateTicks)
        .get();
  }

  getVideoChatbyStudent(
      int fromDateTicks, int toDateTicks, String email) async {
    String userName = email.substring(0, email.indexOf("@")).toUpperCase();
    return await dbHandler
        .collection("VideoChatRoom")
        .where("toUser", isEqualTo: '$userName')
        .where('startDateTime', isGreaterThanOrEqualTo: fromDateTicks)
        .where('startDateTime', isLessThanOrEqualTo: toDateTicks)
        .get();
  }

  updateStudentToken(String clientToken, String documentId) async {
    await dbHandler.collection("Student").doc(documentId).update({
      'clientToken': clientToken,
      'tokenUpdateDate': DateTime.now().millisecondsSinceEpoch
    });
  }

  getAllNotification(String email) async {
    return await dbHandler
        .collection("Notification")
        .where('toEmail', isEqualTo: email.trim().toLowerCase())
        .get();
    //.snapshots();
  }

  getAllNotificationStream(String email) {
    return dbHandler
        .collection("Notification")
        .where('toEmail', isEqualTo: email.trim().toLowerCase())
        .snapshots();
  }

  getAllNotificationStreamChat(String email) {
    return dbHandler
        .collection("Notification")
        .where('toEmail', isEqualTo: email.trim().toLowerCase())
        .snapshots();
  }

  removeNotification(documentid) {
    return dbHandler.collection("Notification").doc(documentid).delete();
  }

  removeNotificationChat(documentid) {
    return dbHandler.collection("Notification").doc(documentid).delete();
  }

  removeAllMyNotification(toEmail) {
    return dbHandler
        .collection("Notification")
        .where('toEmail', isEqualTo: toEmail.trim().toLowerCase())
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}

//DatabaseHandler databaseHandler = DatabaseHandler();
