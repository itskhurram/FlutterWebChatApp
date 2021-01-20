import 'package:myuwi/UserInterface/Home.dart';
import 'package:myuwi/Values/AppValues.dart';
import 'package:myuwi/Widgets/AppSpaces.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:linkable/linkable.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../Repository/DatabaseHandler.dart';

class AddCourse extends StatefulWidget {
  @override
  _AddCourseState createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  String _errorMessage = "";
  String _successMessage = "";
  String firstName = "";
  String lastName = "";
  String emailAddress = "";
  String documentId = "";
  String courseCodeTemp = "",myUserName = "", studentDocumentId = "";
  final dashboardformKey = new GlobalKey<FormState>();
  DatabaseHandler databaseHandler = new DatabaseHandler();
  List<String> _data = [];
  List<String> addcourseList = [];

  bool validate = false;
  checkFields() {
    final form = dashboardformKey.currentState;
    if (form.validate()) {
      return true;
    } else {
      return false;
    }
  }

  validateCourse(String courseCodeTemp) {
    bool exist = false;
    for (var item in _data) {
      if (item.toLowerCase() == courseCodeTemp.toLowerCase()) {
        exist = true;
        break;
      }
    }
    if (exist)
      return "You have already added this course code.";
    else
      return null;
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget showSuccessMessage() {
    if (_successMessage.length > 0 && _successMessage != null) {
      return new Text(
        _successMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.green,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
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
    if (html.window.sessionStorage != null &&
        html.window.sessionStorage['documentId'] != null) {
      studentDocumentId = html.window.sessionStorage['documentId'];
    }

    //print("get data");
    _getData();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
        //backgroundColor: AppColors.ucDavisBlue,
        appBar: AppBar(
          backgroundColor: AppColors.ucDavisBlue,
          leading: IconButton(
              icon: Icon(Icons.menu), color: Colors.white, onPressed: () {}),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                tooltip: "Back",
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (BuildContext ctx) => Home()));
                })
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
        body: getCourseBody(), //getDashboardBody(),
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

  Widget getCourseBody() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
              itemCount: _data.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return Card(
                    child: ListTile(
                  title: Text(_data[index]),
                ));
              }),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                //height: 400.0,
                width: 500.0,
                child: buildQuestionForm(),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget buildQuestionForm() {
    return Center(
      child: Container(
        //height: 200.0,
        width: 500.0,
        child: Column(
          children: <Widget>[
            Form(
                key: dashboardformKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    showErrorMessage(),
                    showSuccessMessage(),
                    //SpaceH20(),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 12.0, bottom: 12.0),
                      child: Container(
                        height: 50.0,
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: new InputDecoration(
                            hintText: "Course Code",
                            hintStyle: TextStyle(color: Colors.white),
                            fillColor: AppColors.ucDavisBlue,
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.white)),
                            filled: true,
                            contentPadding: EdgeInsets.only(
                                bottom: 10.0, left: 10.0, right: 10.0),
                            //labelText: 'Course Code',
                            //labelStyle: TextStyle(color: Colors.white)
                          ),
                          onFieldSubmitted: (value) {
                            if (checkFields()) {
                              this._errorMessage = "";
                              addcourseList = _data;
                              addcourseList.add(
                                  this.courseCodeTemp.toUpperCase().trim());
                              databaseHandler
                                  .saveCourseList(
                                      'Student', addcourseList, studentDocumentId)
                                  .then((value) {
                                if (value != "Error") {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext ctx) =>
                                              Home()));
                                } else {
                                  this._errorMessage =
                                      "Course can't be added at this moment please try again later.";
                                }
                              });
                            }
                          },
                          validator: (value) => value.isEmpty
                              ? 'Course code is required'
                              : validateCourse(value.toUpperCase().trim()),
                          onChanged: (value) => {
                            this.courseCodeTemp = value.toUpperCase().trim()
                          },
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (checkFields()) {
                          this._errorMessage = "";
                          setState(()   {
                            addcourseList = _data;
                            addcourseList
                                .add(this.courseCodeTemp.toUpperCase().trim());

                            databaseHandler
                                .saveCourseList(
                                    'Student', addcourseList, studentDocumentId)
                                .then((value) {
                              if (value != null && value != "") {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext ctx) =>
                                            Home()));
                              } else {
                                this._errorMessage =
                                    "Course can't be added at this moment please try again later.";
                              }
                            });
                          });
                        }
                      },
                      child: Container(
                        height: 50.0,
                        width: 300.0,
                        decoration: BoxDecoration(
                            color: AppColors.ucDavisYellow,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                        child: Center(
                            child: Text('Add  Course',
                                style: new TextStyle(
                                    color: AppColors.ucDavisBlue,
                                    fontSize: 18.0,
                                    backgroundColor: null))),
                      ),
                    ),
                    SpaceH20(),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Future<Null> _getData() async {
    if (html.window.sessionStorage != null &&
        html.window.sessionStorage['email'] != null) {
      emailAddress = html.window.sessionStorage['email'];
    }
    QuerySnapshot coursedata =
        await databaseHandler.getCourseByStudent("Student", emailAddress);
    if (coursedata != null && coursedata.docs.length > 0) {
      setState(() {
        for (var i = 0; i < coursedata.docs.length; i++) {
          documentId = coursedata.docs[i].id;
          var myDocument = coursedata.docs[i].data()["CourseList"];
          //print(myDocument);
          if (myDocument != null) {
            for (var item in myDocument) {
              _data.add(item.toString().toUpperCase());
            }
          } else {
            _data.add(coursedata.docs[i].data()["courseCode"]);
          }
          break;
        }
      });
    }
    if (_data.length == 1 && _data[0] == null) {
      _data = [];
      _data.add("");
    }
    return null;
  }
}
