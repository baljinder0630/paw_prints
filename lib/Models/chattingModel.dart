// ignore_for_file: prefer_typing_uninitialized_variables, unnecessary_this, non_constant_identifier_names, avoid_types_as_parameter_names, camel_case_types

class Chattingmodel {
  var messageId;

  var seen;
  var sendOn;
  var sendtime;
  var sender;

  var lastmessage;

  Chattingmodel(
      {required this.seen,
      required this.sendOn,
      required this.sendtime,
      required this.sender,
      required this.messageId,
      required this.lastmessage});

  Chattingmodel.fromMap(Map<String, dynamic> map) {
    seen = map['seen'];
    sender = map['sender'];
    sendOn = map['sendOn'];
    sendtime = map['sendtime'];
    messageId = map['messageId'];
    lastmessage = map['lastmessage'];
  }

  Map<String, dynamic> toMap() {
    return {
      "seen": this.seen,
      "sender": this.sender,
      "sendOn": this.sendOn,
      "sendtime": this.sendtime,
      "lastmessage": this.lastmessage,
      "messageId": this.messageId
    };
  }
}
