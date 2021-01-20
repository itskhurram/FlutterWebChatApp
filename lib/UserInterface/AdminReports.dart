import 'package:myuwi/Repository/DatabaseHandler.dart';
import 'package:myuwi/UserInterface/Signin.dart';
import 'package:myuwi/Values/AppValues.dart';
import 'package:myuwi/Widgets/AppSpaces.dart';
import 'package:csv/csv.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:intl/intl.dart';

class AdminReports extends StatefulWidget {
  AdminReports({Key key}) : super(key: key);

  @override
  _AdminReportsState createState() => _AdminReportsState();
}

class _AdminReportsState extends State<AdminReports> {
  DatabaseHandler databaseHandler = new DatabaseHandler();
  String firstName = "";
  String lastName = "";
  String emailAddress = "";
  String adminDocumentId = "";
  String isAdmin = "";
  DateTime selectedFromDate = new DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime selectedToDate = DateTime.now();
  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (html.window.sessionStorage != null &&
        html.window.sessionStorage['email'] != null) {
      emailAddress = html.window.sessionStorage['email'];
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
      adminDocumentId = html.window.sessionStorage['documentId'];
    }
    if (html.window.sessionStorage != null &&
        html.window.sessionStorage['IsAdmin'] != null) {
      isAdmin = html.window.sessionStorage['IsAdmin'];
    }
  }

  Widget dateSelectionForm() {
    return Center(
      child: Container(
        height: 500.0,
        width: 550.0,
        child: Column(
          children: <Widget>[
            Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SpaceH20(),
                    //showErrorMessage(),
                    // SpaceH180(),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0, bottom: 25.0),
                      child: Container(
                        height: 70.0,
                        child: DateTimeField(
                          label: "Select From Date",
                          mode: DateFieldPickerMode.date,
                          dateFormat: DateFormat("MM/dd/yyyy"),
                          selectedDate: selectedFromDate,
                          onDateSelected: (DateTime date) {
                            setState(() {
                              selectedFromDate = date;
                            });
                          },
                          lastDate: DateTime.now(),
                          firstDate: DateTime(2020),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0, bottom: 25.0),
                      child: Container(
                        height: 70.0,
                        child: DateTimeField(
                          label: "Select To Date",
                          mode: DateFieldPickerMode.date,
                          dateFormat: DateFormat("MM/dd/yyyy"),
                          selectedDate: selectedToDate,
                          onDateSelected: (DateTime date) {
                            setState(() {
                              selectedToDate = date;
                            });
                          },
                          lastDate: DateTime.now(),
                          firstDate: DateTime(2020),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                            child: Container(
                              height: 50.0,
                              width: 250.0,
                              decoration: BoxDecoration(
                                  color: AppColors.ucDavisYellow,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0))),
                              child: Center(
                                  child: Text('Student Wise Report',
                                      style: new TextStyle(
                                          color: AppColors.ucDavisBlue,
                                          fontFamily: 'Proxima Nova',
                                          fontSize: 18.0,
                                          backgroundColor: null))),
                            ),
                            onTap: () {
                              getStudentReportCsv();
                            }),
                        InkWell(
                            child: Container(
                              height: 50.0,
                              width: 250.0,
                              decoration: BoxDecoration(
                                  color: AppColors.ucDavisYellow,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0))),
                              child: Center(
                                  child: Text('Course Wise Report',
                                      style: new TextStyle(
                                          color: AppColors.ucDavisBlue,
                                          fontFamily: 'Proxima Nova',
                                          fontSize: 18.0,
                                          backgroundColor: null))),
                            ),
                            onTap: () {
                              getCourseReportCsv();
                            }),
                      ],
                    ),

                    SpaceH16(),
                    SpaceH16(),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.ucDavisBlue,
          iconTheme: new IconThemeData(color: AppColors.ucDavisWhite),
          actions: <Widget>[
            FlatButton.icon(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                  semanticLabel: 'Sign out',
                ),
                label: Text("Sign out",
                    style: new TextStyle(
                        color: Colors.white, fontFamily: 'Proxima Nova')),
                onPressed: () {
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

                  databaseHandler.updatelogoutTimeAdmin(
                      documentId, loginInTime, totalLoggedInTime);
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
        body: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              dateSelectionForm()
              //Icon(Icons.adjust, size: 50.0, color: Colors.cyan,),
            ],
          ),
        ));
  }

  String getSpentTimeLeftManu(millisecondsSpent) {
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

  getStudentReportCsv() async {
    List<List<dynamic>> rows = [];
    rows.add([
      "Last Name",
      "First Name",
      "Email",
      "Total Time Helped",
      "Unique Users Helped",
      "Total Question Posted",
      "Total Question Marked Resolved"
    ]);
    await databaseHandler.getAllStudents().then((studentWiseReportList) async {
      if (studentWiseReportList != null &&
          studentWiseReportList.docs.length > 0) {
        for (var studentRecord in studentWiseReportList.docs) {
          List<dynamic> row = [];
          row.add(studentRecord.data()['lastName']);
          row.add(studentRecord.data()['firstName']);
          row.add(studentRecord.data()['email']);
          DateTime selectedTo = new DateTime(selectedToDate.year,
              selectedToDate.month, selectedToDate.day, 23, 59);
          await databaseHandler
              .getVideoChatbyStudent(
                  selectedFromDate.millisecondsSinceEpoch,
                  selectedTo.millisecondsSinceEpoch,
                  studentRecord.data()['email'])
              .then((videoChatList) async {
            int millisecondsSpent = 0;
            List<String> userList = [];
            if (videoChatList != null && videoChatList.docs.length > 0) {
              for (var doc in videoChatList.docs) {
                if (doc.data()['totalMilliSecondsSpent'] != null)
                  millisecondsSpent += doc.data()['totalMilliSecondsSpent'];
                if (!userList.contains(doc.data()['fromUser'])) {
                  userList.add(doc.data()['fromUser']);
                }
              }
              row.add(getSpentTimeLeftManu(millisecondsSpent));
              row.add(userList.length.toString());
            } else {
              row.add(getSpentTimeLeftManu(millisecondsSpent));
              row.add(userList.length.toString());
            }
            await databaseHandler
                .getAllQuestionsByStudent(
                    selectedFromDate.millisecondsSinceEpoch,
                    selectedTo.millisecondsSinceEpoch,
                    studentRecord.data()['email'])
                .then((questionList) {
              if (questionList != null && questionList.docs.length > 0) {
                row.add(questionList.docs.length.toString());
                int resolved = 0;
                for (var question in questionList.docs) {
                  if (question
                          .data()['status']
                          .toString()
                          .trim()
                          .toLowerCase() ==
                      'resolved') {
                    resolved = resolved + 1;
                  }
                }
                row.add(resolved.toString());
              } else {
                row.add("0");
                row.add("0");
              }
              rows.add(row);
            });
          });
        }
        // File f = await _localFile;
        String csv = const ListToCsvConverter().convert(rows);
        String encodedFileContents = Uri.encodeComponent(csv);
        //print(encodedFileContents);
        new html.AnchorElement(href: "data:text, $encodedFileContents")
          ..setAttribute("download", "StudentWiseReport.csv")
          ..click();
      }
    });
  }

  getCourseReportCsv() async {
    List<List<dynamic>> rows = [];
    rows.add([
      "Course Name",
      "Question",
      "Student ID who Posted the Question",
      "Question Posted Time",
      "Question Resolution Time"
    ]);
    DateTime selectedTo = new DateTime(
        selectedToDate.year, selectedToDate.month, selectedToDate.day, 23, 59);
    await databaseHandler
        .getAllQuestions(selectedFromDate.millisecondsSinceEpoch,
            selectedTo.millisecondsSinceEpoch)
        .then((courseWiseReportList) async {
      if (courseWiseReportList != null &&
          courseWiseReportList.docs.length > 0) {
        for (var question in courseWiseReportList.docs) {
          List<dynamic> row = [];
          row.add(question.data()['courseCode']);
          row.add(question.data()['question']);
          row.add(question.data()['email']);
          row.add(new DateTime.fromMillisecondsSinceEpoch(
              question.data()['createdDate']));
          //statusDate
          if (question.data()['statusDate'] != null) {
            row.add(new DateTime.fromMillisecondsSinceEpoch(
                question.data()['statusDate']));
          } else {
            row.add("");
          }
          rows.add(row);
        }

        String csv = const ListToCsvConverter().convert(rows);
        String encodedFileContents = Uri.encodeComponent(csv);
        new html.AnchorElement(href: "data:text, $encodedFileContents")
          ..setAttribute("download", "CourseWiseReport.csv")
          ..click();
      }
    });
  }
}
