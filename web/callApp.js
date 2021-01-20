function joinCall(question, questionownerEmail, firstName, lastName,email,isOwner,ownerStudentId,courseCode,helperStudentid) {

    const encodedFname = UCDavisRot13(firstName.toUpperCase());
    const encodedLname = UCDavisRot13(lastName.toUpperCase());
    const emailAddress = UCDavisRot13(email.toUpperCase());
    const questionownerEmailAddress = UCDavisRot13(questionownerEmail.toUpperCase());
    const isOwnerofQuestion = isOwner;
    const encodedCourseCode = UCDavisRot13(courseCode.toUpperCase());
    const ownerStudentID = ownerStudentId;
    const helperStudentiD = helperStudentid;
  
  
    window.open(
      "callApp.html?room=" +
        question + 
        "&fn=" +
        encodedFname +
        "&ln=" +
        encodedLname+
        "&em=" +
        emailAddress +
        "&qoem=" +
        questionownerEmailAddress+
        "&isOwner="+ isOwnerofQuestion+
        "&cc="+ encodedCourseCode+
        "&osid="+ ownerStudentID+
        "&hsid="+ helperStudentiD
    );
  }
  
  function UCDavisRot13(str) {
    if (str != null && str != undefined) {
      chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      return str.split("").reduce(function (a, b) {
        if (chars.indexOf(b) == -1) {
          return a + b;
        }
        return a + chars[(chars.indexOf(b) + 13) % chars.length];
      }, "");
    } else return "";
  }
  