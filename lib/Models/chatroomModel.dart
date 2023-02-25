// ignore_for_file: prefer_typing_uninitialized_variables, unnecessary_this, non_constant_identifier_names, avoid_types_as_parameter_names, camel_case_types

import 'dart:ffi';

class Chatroommodel {
  var chatroomuid;

  Map<String, dynamic>? participants;

  var lastmessage;

  Chatroommodel(
      {required this.participants,
      required this.chatroomuid,
      required this.lastmessage});

  Chatroommodel.fromMap(Map<String, dynamic> map) {
    participants = map['participants'];
    chatroomuid = map['chatroomuid'];
    lastmessage = map['lastmessage'];
  }

  Map<String, dynamic> toMap() {
    return {
      "participants": this.participants,
      "lastmessage": this.lastmessage,
      "chatroomuid": this.chatroomuid
    };
  }
}
