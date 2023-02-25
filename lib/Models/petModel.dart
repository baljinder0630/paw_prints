import 'package:geolocator/geolocator.dart';

class PetModel {
  late String name;
  String? dob;
  String? pic;
  var petId;
  String? description;
  String? sellingBy;
  String? buyedBy;
  double? lat;
  double? long;
  List<dynamic>? likedBy;

  PetModel(
      {required this.name,
      required this.petId,
      this.likedBy,
      this.sellingBy,
      this.buyedBy,
      this.dob,
      this.pic,
      this.description,
      required this.lat,
      required this.long});

  PetModel.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    sellingBy = map['sellingBy'];
    buyedBy = map['buyedBy'];
    likedBy = map['likedBy'];
    dob = map['dob'];
    pic = map['pic'];
    petId = map['petId'];
    description = map['description'];
    lat = map['lat'];
    long = map['long'];
  }
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "sellingBy": sellingBy,
      "sellingBy": sellingBy,
      "buyedBy": buyedBy,
      "likedBy": likedBy,
      "dob": dob,
      "pic": pic,
      "description": description,
      "petId": petId,
      "lat": lat,
      "long": long
    };
  }
}
