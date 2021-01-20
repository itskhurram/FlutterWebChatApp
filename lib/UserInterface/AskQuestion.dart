import 'package:myuwi/UserInterface/Home.dart';
import 'package:myuwi/Values/AppValues.dart';
import 'package:myuwi/Widgets/AppSpaces.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:linkable/linkable.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../Repository/DatabaseHandler.dart';

class AskQuestion extends StatefulWidget {
  @override
  _AskQuestionState createState() => _AskQuestionState();
}

class _AskQuestionState extends State<AskQuestion> {
  String question = "";
  String _errorMessage = "";
  String _successMessage = "";
  String firstName = "";
  String lastName = "";
  String emailAddress = "";
  String courseCode = "";
  String dropdownValue = '';
  final dashboardformKey = new GlobalKey<FormState>();
  DatabaseHandler databaseHandler = new DatabaseHandler();
  final questionField = TextEditingController();
  List<String> _data = [];
  bool validate = false;

  @override
  void initState() {
    super.initState();
    //print("get data");
    _getData();
  }

  @override
  Widget build(BuildContext context) {
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
        html.window.sessionStorage['courseCode'] != null) {
      courseCode = html.window.sessionStorage['courseCode'];
    }

    return Scaffold(
        //backgroundColor: AppColors.ucDavisBlue,
        appBar: AppBar(
          backgroundColor: AppColors.ucDavisBlue,
          iconTheme: new IconThemeData(color: AppColors.ucDavisWhite),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                tooltip: "Back",
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext ctx) => Home()));
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
        body: getDashboardBody(),
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

  Widget getDashboardBody() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          children: <Widget>[
            Center(
              child: Container(
                height: 400.0,
                width: 600.0,
                child: buildQuestionForm(),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget buildQuestionForm() {
    final maxLines = 5;
    return Center(
      child: Container(
        height: 500.0,
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
                    SpaceH20(),
                    SpaceH20(),
                    Container(
                      margin: EdgeInsets.all(12),
                      height: maxLines * 24.0,
                      child: TextField(
                        controller: questionField,
                        maxLines: maxLines,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter your question",
                          hintStyle: TextStyle(color: Colors.white),
                          //labelText: 'Question',
                          //  labelStyle: TextStyle(color: Colors.white),
                          fillColor: AppColors.ucDavisBlue,
                          filled: true,
                          errorText:
                              validate ? 'Question can\'t be empty' : null,
                        ),
                      ),
                    ),
                    Padding(
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
                            });
                          },
                          items: _data
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          questionField.text.isEmpty
                              ? validate = true
                              : validate = false;
                        });
                        if (checkFields() && questionField.text.isNotEmpty) {
                          this._errorMessage = "";
                          this.question = questionField.text;
                          databaseHandler
                              .saveQuestion('Question', question, emailAddress,
                                  dropdownValue)
                              .then((String question) {
                            setState(() {
                              if (question != null && question.isNotEmpty) {
                                this.question = '';
                                this._errorMessage = "";
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext ctx) =>
                                            Home()));
                              } else {
                                this._successMessage = "";
                                this._errorMessage =
                                    "There is some problem while adding question. Please try again later.";
                              }
                            });
                          });
                        } else {
                          //this._errorMessage = "Please fill required fields.";
                          return false;
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
                            child: Text('POST',
                                style: new TextStyle(
                                    color: AppColors.ucDavisBlue,
                                    fontSize: 18.0,
                                    backgroundColor: null))),
                      ),
                    )
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
          //documentId = coursedata.documents[i].documentID;
          var myDocument = coursedata.docs[i].data()["CourseList"];
          //print(myDocument);
          if (myDocument != null) {
            for (var item in myDocument) {
              _data.add(item.toString());
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

  checkFields() {
    final form = dashboardformKey.currentState;
    if (form.validate()) {
      return true;
    } else {
      return false;
    }
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
}
