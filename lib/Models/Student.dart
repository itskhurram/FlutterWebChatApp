class Student {
  String _id;
  String _firstName;
  // String _middleName;
  String _lastName;
  String _email;
  String _password;
  String _courseCode;
  // bool _isActive;
  // int _totalQuestionTime; //Time in Mins
  // int _totalAnswerTime; //Time in Mins
  // DateTime _createdDate;
  // String _createdBy;

  String get id {
    return _id;
  }

  set id(String id) {
    this._id = id;
  }

  String get firstName {
    return _firstName;
  }

  set firstName(String fname) {
    this._firstName = fname;
  }

  String get lastName {
    return _lastName;
  }

  set lastName(String lastName) {
    this._lastName = lastName;
  }

  String get courseCode {
    return _courseCode;
  }

  set courseCode(String ccode) {
    this._courseCode = ccode;
  }

  String get email {
    return _email;
  }

  set email(String mail) {
    this._email = mail;
  }

  String get password {
    return _password;
  }

  set password(String pass) {
    this._password = pass;
  }
}
