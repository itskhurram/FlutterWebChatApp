import 'package:myuwi/Values/AppValues.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final String sender;
  final bool sendByMe;
  final receiveTime;
  final dateTime = DateTime.now();

  MessageTile({@required this.message, @required  this.sender  , @required this.sendByMe,@required this.receiveTime}); 
  @override
  Widget build(BuildContext context) {
    // return Container(
    //   padding: EdgeInsets.only(
    //       top: 8,
    //       bottom: 10,
    //       left: sendByMe ? 0 : 10,
    //       right: sendByMe ? 10 : 0),
    //   alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
    //   child: Container(
    //     margin:
    //         sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
    //     padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
    //     decoration: BoxDecoration(
    //         borderRadius: sendByMe
    //             ? BorderRadius.only(
    //                 topLeft: Radius.circular(23),
    //                 topRight: Radius.circular(23),
    //                 bottomLeft: Radius.circular(23))
    //             : BorderRadius.only(
    //                 topLeft: Radius.circular(23),
    //                 topRight: Radius.circular(23),
    //                 bottomRight: Radius.circular(23)),
    //         gradient: LinearGradient(
    //           colors: sendByMe
    //               ? [AppColors.ucDavisYellow, AppColors.ucDavisYellow]
    //               : [AppColors.ucDavisBlue, AppColors.ucDavisBlue],
    //         )),
    //     child: Text(message + "\r\n"+
    //                 DateTimeFormat.format(new DateTime.fromMillisecondsSinceEpoch(this.receiveTime), format: DateTimeFormats.americanAbbr).toString(),
    //                 softWrap: true,
    //         textAlign: TextAlign.start,
    //         style: TextStyle(
    //             color: Colors.white,
    //             fontSize: 16,
    //             fontFamily: 'Proxima Nova',
    //             fontWeight: FontWeight.w500)),
    //   ),
    // );
    return Container(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: sendByMe ? 0 : 10,
        right: sendByMe ? 10 : 0),
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
          decoration: BoxDecoration(
          borderRadius: sendByMe ? BorderRadius.only(
            topLeft: Radius.circular(23),
            topRight: Radius.circular(23),
            bottomLeft: Radius.circular(23)
          )
          :BorderRadius.only(
            topLeft: Radius.circular(23),
            topRight: Radius.circular(23),
            bottomRight: Radius.circular(23)
          ),
          //color: sendByMe ? Colors.blueAccent : Colors.grey[700],
          gradient: LinearGradient(
               colors: sendByMe
                   ? [AppColors.ucDavisYellow, AppColors.ucDavisYellow]
                   : [AppColors.ucDavisBlue, AppColors.ucDavisBlue],
             )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(sender.toUpperCase(), textAlign: TextAlign.start, style: TextStyle(fontSize: 11.0, fontFamily: 'Proxima Nova', fontWeight: FontWeight.bold, 
            color: sendByMe ? AppColors.ucDavisBlue : AppColors.ucDavisYellow, 
            letterSpacing: -0.5)),
            SizedBox(height: 7.0),
            Text(message + "\r\n"+  DateTimeFormat.format(new DateTime.fromMillisecondsSinceEpoch(this.receiveTime), format: DateTimeFormats.americanAbbr).toString(), softWrap: true, textAlign: TextAlign.start, style: TextStyle(color: Colors.white,fontSize: 12,fontFamily: 'Proxima Nova', fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
