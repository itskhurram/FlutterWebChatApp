import 'package:myuwi/Repository/DatabaseHandler.dart';
import 'package:myuwi/UserInterface/AddCourse.dart';
import 'package:myuwi/UserInterface/AdminReports.dart';
import 'package:myuwi/UserInterface/DrawDesignLines.dart';
import 'package:myuwi/UserInterface/Home.dart';
import 'package:myuwi/UserInterface/Signup.dart';
import 'package:myuwi/Values/AppValues.dart';
import 'package:myuwi/Widgets/AppSpaces.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:linkable/linkable.dart';

class SignIn extends StatefulWidget {
  SignIn({Key key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String email, password;
  String _errorMessage = "";
  final formKey = new GlobalKey<FormState>();
  DatabaseHandler databaseHandler = new DatabaseHandler();
  checkFields() {
    final form = formKey.currentState;
    if (form.validate()) {
      return true;
    } else {
      return false;
    }
  }

  validateEmail(String emailAddress) {
    emailAddress = emailAddress.trim().toLowerCase();
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (regExp.hasMatch(emailAddress)) {
      if (emailAddress.indexOf('my.uwi.edu') != -1 &&
          (emailAddress.length - '@my.uwi.edu'.length) != 0) {
        return null; //valid Email Address
      } else {
        return "Enter valid my.uwi.edu domain email.";
      }
    } else {
      return "Enter valid my.uwi.edu domain email.";
    }
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 16.0,
            fontFamily: 'Proxima Nova',
            color: AppColors.ucDavisYellow,
            height: 2.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.ucDavisBlue,
        body: bodyWidgets(),
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

  Widget bodyWidgets() {
    return ListView(
      children: <Widget>[
        //getLines(),
        getLogo(),
        signInForm(),
      ],
    );
  }

  Widget getLines() {
    return Center(
      child: CustomPaint(
        size: Size(0, 25),
        painter: DrawDesignLines(),
      ),
    );
  }

  Widget getLogo() {
    return Padding(
      padding: EdgeInsets.all(25.0),
      child: Image.asset("assets/images/UCBOOST_WHITE.png",
          height: 90.0, width: 300.0),
    );
  }

  Widget signInForm() {
    return Center(
      child: Container(
        height: 500.0,
        width: 500.0,
        child: Column(
          children: <Widget>[
            SpaceH20(),
            SpaceH20(),
            Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SpaceH20(),
                    showErrorMessage(),
                    // SpaceH180(),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0, bottom: 25.0),
                      child: Container(
                        height: 50.0,
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: new InputDecoration(
                              fillColor: AppColors.ucDavisBlue,
                              border: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.white)),
                              filled: true,
                              contentPadding: EdgeInsets.only(
                                  bottom: 5.0, left: 5.0, right: 5.0),
                              labelText: 'Student Email (user@my.uwi.edu)',
                              labelStyle: TextStyle(color: Colors.white)),
                          onFieldSubmitted: (value) {
                            if (checkFields()) {
                              this._errorMessage = "";
                              databaseHandler
                                  .signIn('Student', email, password)
                                  .then((value) {
                                if (value != null && value.docs.length > 0) {
                                  for (int i = 0; i < value.docs.length; i++) {
                                    if (value.docs[i]
                                                .data()['email']
                                                .toString()
                                                .trim()
                                                .toLowerCase() !=
                                            "" &&
                                        value.docs[i]
                                                .data()['email']
                                                .toString()
                                                .trim()
                                                .toLowerCase() ==
                                            email.trim().toLowerCase()) {
                                      // databaseHandler.updateLoginTime(
                                      //     value.docs[i].documentID);

                                      html.window.sessionStorage['documentId'] =
                                          value.docs[i].id;
                                      html.window.sessionStorage[
                                              'totalLoggedInTime'] =
                                          value.docs[i]
                                              .data()['totalLoggedInTime']
                                              .toString();

                                      html.window.sessionStorage[
                                              'totalHelpedSpentMilliSeconds'] =
                                          value.docs[i]
                                              .data()[
                                                  'totalHelpedSpentMilliSeconds']
                                              .toString();

                                      html.window
                                              .sessionStorage['loginInTime'] =
                                          DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString();

                                      html.window.sessionStorage['firstName'] =
                                          value.docs[i].data()['firstName'];
                                      html.window.sessionStorage['lastName'] =
                                          value.docs[i].data()['lastName'];
                                      html.window.sessionStorage['courseCode'] =
                                          value.docs[i].data()['courseCode'];
                                      html.window.sessionStorage['email'] =
                                          value.docs[i].data()['email'];
                                      break;
                                    }
                                  }
                                  if (html.window
                                              .sessionStorage['courseCode'] !=
                                          null &&
                                      html.window.sessionStorage['courseCode']
                                          .toString()
                                          .isNotEmpty) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                Home()));
                                  }
                                } else {
                                  this._errorMessage =
                                      "Invalid Username/Password.";
                                }
                              });
                            }
                          },
                          validator: (value) => value.isEmpty
                              ? 'Email is required'
                              : validateEmail(value.trim()),
                          onChanged: (value) => {this.email = value},
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0, bottom: 25.0),
                      child: Container(
                        height: 50.0,
                        child: TextFormField(
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Proxima Nova',
                              fontSize: 14),
                          decoration: new InputDecoration(
                              fillColor: AppColors.ucDavisBlue, //Colors.white,
                              border: InputBorder
                                  .none, //OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow, width: 15.0),),//InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.white)),
                              filled: true,
                              contentPadding: EdgeInsets.only(
                                  bottom: 5.0, left: 5.0, right: 5.0),
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Proxima Nova',
                                  fontSize: 14)),
                          obscureText: true,
                          onFieldSubmitted: (value) {
                            if (checkFields()) {
                              this._errorMessage = "";
                              databaseHandler
                                  .signIn('Student', email, password)
                                  .then((value) {
                                if (value != null && value.docs.length > 0) {
                                  for (int i = 0; i < value.docs.length; i++) {
                                    if (value.docs[i]
                                                .data()['email']
                                                .toString()
                                                .trim()
                                                .toLowerCase() !=
                                            "" &&
                                        value.docs[i]
                                                .data()['email']
                                                .toString()
                                                .trim()
                                                .toLowerCase() ==
                                            email.trim().toLowerCase()) {
                                      html.window.sessionStorage['documentId'] =
                                          value.docs[i].id;
                                      html.window.sessionStorage[
                                              'totalLoggedInTime'] =
                                          value.docs[i]
                                              .data()['totalLoggedInTime']
                                              .toString();
                                      html.window.sessionStorage[
                                              'totalHelpedSpentMilliSeconds'] =
                                          value.docs[i]
                                              .data()[
                                                  'totalHelpedSpentMilliSeconds']
                                              .toString();
                                      html.window
                                              .sessionStorage['loginInTime'] =
                                          DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString();
                                      html.window.sessionStorage['firstName'] =
                                          value.docs[i].data()['firstName'];
                                      html.window.sessionStorage['lastName'] =
                                          value.docs[i].data()['lastName'];
                                      html.window.sessionStorage['email'] =
                                          value.docs[i].data()['email'];
                                           html.window.sessionStorage['IsAdmin'] =
                                          value.docs[i].data()['IsAdmin'].toString();
                                      break;
                                    }
                                  }

                                  if (value.docs[0].data()['IsAdmin'] == 1) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                AdminReports()));
                                  } else {
                                    if (value.docs[0].data()['CourseList'] !=
                                        null) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext ctx) =>
                                                  Home()));
                                    } else {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext ctx) =>
                                                  AddCourse()));
                                    }
                                  }
                                } else {
                                  setState(() {
                                    this._errorMessage =
                                        "Invalid Username/Password.";
                                  });
                                }
                              });
                            }
                          },
                          validator: (value) =>
                              value.isEmpty ? 'Password is required' : null,
                          onChanged: (value) => {this.password = value},
                        ),
                      ),
                    ),
                    InkWell(
                        child: Container(
                          height: 50.0,
                          width: 300.0,
                          decoration: BoxDecoration(
                              color: AppColors.ucDavisYellow,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0))),
                          child: Center(
                              child: Text('SIGN IN',
                                  style: new TextStyle(
                                      color: AppColors.ucDavisBlue,
                                      fontFamily: 'Proxima Nova',
                                      fontSize: 18.0,
                                      backgroundColor: null))),
                        ),
                        onTap: () {
                          if (checkFields()) {
                            this._errorMessage = "";

                            databaseHandler
                                .signIn('Student', email, password)
                                .then((value) {
                              if (value != null && value.docs.length > 0) {
                                for (int i = 0; i < value.docs.length; i++) {
                                  if (value.docs[i]
                                              .data()['email']
                                              .toString()
                                              .trim()
                                              .toLowerCase() !=
                                          "" &&
                                      value.docs[i]
                                              .data()['email']
                                              .toString()
                                              .trim()
                                              .toLowerCase() ==
                                          email.trim().toLowerCase()) {
                                    //     databaseHandler.updateLoginTime(
                                    // value.docs[i].documentID);

                                    html.window.sessionStorage['documentId'] =
                                        value.docs[i].id;
                                    html.window.sessionStorage[
                                            'totalLoggedInTime'] =
                                        value.docs[i]
                                            .data()['totalLoggedInTime']
                                            .toString();

                                    html.window.sessionStorage[
                                            'totalHelpedSpentMilliSeconds'] =
                                        value.docs[i]
                                            .data()[
                                                'totalHelpedSpentMilliSeconds']
                                            .toString();

                                    html.window.sessionStorage['loginInTime'] =
                                        DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString();

                                    html.window.sessionStorage['firstName'] =
                                        value.docs[i].data()['firstName'];
                                    html.window.sessionStorage['lastName'] =
                                        value.docs[i].data()['lastName'];
                                    html.window.sessionStorage['email'] =
                                        value.docs[i].data()['email'];
                                         html.window.sessionStorage['IsAdmin'] =
                                        value.docs[i].data()['IsAdmin'].toString();
                                    break;
                                  }
                                }

                                if (value.docs[0].data()['IsAdmin'] == 1) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext ctx) =>
                                              AdminReports()));
                                } else {
                                  if (value.docs[0].data()['CourseList'] !=
                                      null) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                Home()));
                                  } else {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                AddCourse()));
                                  }
                                }
                              } else {
                                setState(() {
                                  this._errorMessage =
                                      "Invalid Username/Password.";
                                });
                                // this._errorMessage =
                                //     "Invalid Username/Password.";
                                return false;
                              }
                            });
                          }
                        }),
                    SpaceH16(),
                    Text(
                      "Don't have an account?",
                      style: new TextStyle(
                          color: AppColors.ucDavisYellow,
                          fontFamily: 'Proxima Nova',
                          backgroundColor: null),
                    ),
                    InkWell(
                      child: Container(
                        width: 50.0,
                        child: Center(
                            child: Text(
                          'Sign up',
                          style: new TextStyle(
                              color: Colors.blue, backgroundColor: null),
                        )),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext ctx) => Signup()));
                      },
                    ),
                    SpaceH16(),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
