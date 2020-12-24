import 'package:cloud_firestore/cloud_firestore.dart';

class Photo {
  String id;
  String description;
  String gpsLocation;
  String image;
  Timestamp createdAt;
  Timestamp updatedAt;

  Photo();

  Photo.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    description = data['description'];
    gpsLocation = data['gpsLocation'];
    image = data['image'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'gpsLocation': gpsLocation,
      'image': image,
      'createdAt': createdAt,
      'updatedAt': updatedAt
    };
  }
}
