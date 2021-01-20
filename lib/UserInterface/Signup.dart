import 'package:myuwi/Repository/DatabaseHandler.dart';
import 'package:myuwi/UserInterface/AddCourse.dart';
import 'package:myuwi/UserInterface/DrawDesignLines.dart';
import 'package:myuwi/UserInterface/Signin.dart';
import 'package:myuwi/Values/AppValues.dart';
import 'package:myuwi/Widgets/AppSpaces.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:linkable/linkable.dart';

class Signup extends StatefulWidget {
  Signup({Key key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String firstName, lastName, email, password, confirmPassword;
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
        signupForm()
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

  Widget signupForm() {
    return Center(
      child: Container(
        height: 700.0,
        width: 500.0,
        child: Column(
          children: <Widget>[
            Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    showErrorMessage(),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0, bottom: 5.0),
                      child: Container(
                        height: 50.0,
                        child: TextFormField(
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Proxima Nova',
                              fontSize: 14),
                          decoration: new InputDecoration(
                              fillColor: AppColors.ucDavisBlue,
                              border: InputBorder
                                  .none, //OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow, width: 15.0),),//InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.white)),
                              filled: true,
                              contentPadding: EdgeInsets.only(
                                  bottom: 5.0, left: 5.0, right: 5.0),
                              labelText: 'First Name',
                              //hintText: 'First Name',
                              //hintStyle: TextStyle(color: Colors.blue),
                              labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Proxima Nova',
                                  fontSize: 14)),
                          validator: (value) =>
                              value.isEmpty ? 'First name is required' : null,
                          onChanged: (value) => {this.firstName = value},
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0, bottom: 5.0),
                      child: Container(
                        height: 50.0,
                        child: TextFormField(
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Proxima Nova',
                              fontSize: 14),
                          decoration: new InputDecoration(
                              fillColor: AppColors.ucDavisBlue,
                              border: InputBorder
                                  .none, //OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow, width: 15.0),),//InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.white)),
                              filled: true,
                              contentPadding: EdgeInsets.only(
                                  bottom: 10.0, left: 10.0, right: 10.0),
                              labelText: 'Last Name',
                              labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Proxima Nova',
                                  fontSize: 14)),
                          validator: (value) =>
                              value.isEmpty ? 'Last name is required' : null,
                          onChanged: (value) => {this.lastName = value},
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0, bottom: 5.0),
                      child: Container(
                        height: 50.0,
                        child: TextFormField(
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Proxima Nova',
                              fontSize: 14),
                          decoration: new InputDecoration(
                              fillColor: AppColors.ucDavisBlue,
                              border: InputBorder
                                  .none, //OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow, width: 15.0),),//InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.white)),
                              filled: true,
                              contentPadding: EdgeInsets.only(
                                  bottom: 5.0, left: 5.0, right: 5.0),
                              labelText: 'Student Email (user@my.uwi.edu)',
                              //hintText: 'user@my.uwi.edu',
                              //hintStyle: TextStyle(color: Colors.white),
                              labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Proxima Nova',
                                  fontSize: 14)),
                          validator: (value) => value.isEmpty
                              ? 'Email is required'
                              : validateEmail(value.trim()),
                          onChanged: (value) => {this.email = value},
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0, bottom: 5.0),
                      child: Container(
                        height: 50.0,
                        child: TextFormField(
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Proxima Nova',
                              fontSize: 14),
                          decoration: new InputDecoration(
                              fillColor: AppColors.ucDavisBlue,
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
                          validator: (value) =>
                              value.isEmpty ? 'Password is required' : null,
                          onChanged: (value) => {this.password = value},
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0, bottom: 5.0),
                      child: Container(
                        height: 50.0,
                        child: TextFormField(
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Proxima Nova',
                              fontSize: 14),
                          decoration: new InputDecoration(
                              fillColor: AppColors.ucDavisBlue,
                              border: InputBorder
                                  .none, //OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow, width: 15.0),),//InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.white)),
                              filled: true,
                              contentPadding: EdgeInsets.only(
                                  bottom: 5.0, left: 5.0, right: 5.0),
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Proxima Nova',
                                  fontSize: 14)),
                          obscureText: true,
                          validator: (value) {
                            if (value.isEmpty)
                              return 'Confirm password is required';
                            if (value != this.password)
                              return 'Password not match';
                            return null;
                          },
                          onChanged: (value) => {this.confirmPassword = value},
                          onFieldSubmitted: (value) {
                            if (checkFields()) {
                              this._errorMessage = "";

                              databaseHandler
                                  .checkExistanceNsignUP("Student", firstName,
                                      lastName, email, password)
                                  .then((result) {
                                setState(() {
                                  if (result != null) {
                                    html.window.sessionStorage['documentId'] =
                                        result.id.toString();
                                    html.window.sessionStorage[
                                        'totalLoggedInTime'] = "0";

                                    html.window.sessionStorage[
                                        'totalHelpedSpentMilliSeconds'] = "0";

                                    html.window.sessionStorage['loginInTime'] =
                                        DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString();

                                    html.window.sessionStorage['email'] = email;
                                    html.window.sessionStorage['firstName'] =
                                        firstName;
                                    html.window.sessionStorage['lastName'] =
                                        lastName;
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                AddCourse()));
                                  } else {
                                    this._errorMessage = "User already exist.";
                                  }
                                });
                              });

                              
                            }
                          },
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (checkFields()) {
                          this._errorMessage = "";

                              databaseHandler
                                  .checkExistanceNsignUP("Student", firstName,
                                      lastName, email, password)
                                  .then((result) {
                               setState(() {
                                  if (result != null) {
                                    html.window.sessionStorage['documentId'] =
                                        result.id.toString();
                                    html.window.sessionStorage[
                                        'totalLoggedInTime'] = "0";

                                    html.window.sessionStorage[
                                        'totalHelpedSpentMilliSeconds'] = "0";

                                    html.window.sessionStorage['loginInTime'] =
                                        DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString();

                                    html.window.sessionStorage['email'] = email;
                                    html.window.sessionStorage['firstName'] =
                                        firstName;
                                    html.window.sessionStorage['lastName'] =
                                        lastName;
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                AddCourse()));
                                  } else {
                                    this._errorMessage = "User already exist.";
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
                            child: Text('SIGN UP',
                                style: new TextStyle(
                                    color: AppColors.ucDavisBlue,
                                    fontSize: 18.0,
                                    fontFamily: 'Proxima Nova',
                                    backgroundColor: null))),
                      ),
                    ),
                    SpaceH16(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
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
                              'Sign in',
                              style: new TextStyle(
                                  color: Colors.blue,
                                  fontFamily: 'Proxima Nova',
                                  backgroundColor: null),
                            )),
                          ),
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext ctx) => SignIn()));
                          },
                        ),
                      ],
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
