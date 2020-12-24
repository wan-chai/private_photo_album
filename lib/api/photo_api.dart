import 'dart:io';

import 'package:private_photo_album/model/photo.dart';
import 'package:private_photo_album/model/user.dart';
import 'package:private_photo_album/notifier/auth_notifier.dart';
import 'package:private_photo_album/notifier/photo_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

login(User user, AuthNotifier authNotifier) async {
  AuthResult authResult = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: user.email, password: user.password)
      .catchError((error) => print(error.code));

  if (authResult != null) {
    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      print("Log In: $firebaseUser");
      authNotifier.setUser(firebaseUser);
    }
  }
}

signup(User user, AuthNotifier authNotifier) async {
  AuthResult authResult = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: user.email, password: user.password)
      .catchError((error) => print(error.code));

  if (authResult != null) {
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = user.displayName;

    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      await firebaseUser.updateProfile(updateInfo);

      await firebaseUser.reload();

      print("Sign up: $firebaseUser");

      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
      authNotifier.setUser(currentUser);
    }
  }
}

signout(AuthNotifier authNotifier) async {
  await FirebaseAuth.instance.signOut().catchError((error) => print(error.code));

  authNotifier.setUser(null);
}

initializeCurrentUser(AuthNotifier authNotifier) async {
  FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();

  if (firebaseUser != null) {
    print(firebaseUser);
    authNotifier.setUser(firebaseUser);
  }
}

getPhotos(PhotoNotifier photoNotifier) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection('Collection')
      .orderBy("createdAt", descending: true)
      .getDocuments();

  List<Photo> _photoList = [];

  snapshot.documents.forEach((document) {
    Photo photo = Photo.fromMap(document.data);
    _photoList.add(photo);
  });

  photoNotifier.photoList = _photoList;
}

uploadPhotoAndImage(Photo photo, bool isUpdating, File localFile, Function photoUploaded) async {
  if (localFile != null) {
    print("uploading image");

    var fileExtension = path.extension(localFile.path);
    print(fileExtension);

    var uuid = Uuid().v4();

    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('photos/images/$uuid$fileExtension');

    await firebaseStorageRef.putFile(localFile).onComplete.catchError((onError) {
      print(onError);
      return false;
    });

    String url = await firebaseStorageRef.getDownloadURL();
    print("download url: $url");
    _uploadPhoto(photo, isUpdating, photoUploaded, imageUrl: url);
  } else {
    print('...skipping image upload');
    _uploadPhoto(photo, isUpdating, photoUploaded);
  }
}

_uploadPhoto(Photo photo, bool isUpdating, Function photoUploaded, {String imageUrl}) async {
  CollectionReference photoRef = Firestore.instance.collection('Collection');

  if (imageUrl != null) {
    photo.image = imageUrl;
  }

  if (isUpdating) {
    photo.updatedAt = Timestamp.now();
    await photoRef.document(photo.id).updateData(photo.toMap());
    photoUploaded(photo);
    print('updated photo with id: ${photo.id}');
  } 
  else {
    photo.createdAt = Timestamp.now();
    DocumentReference documentRef = await photoRef.add(photo.toMap());
    photo.id = documentRef.documentID;
    print('uploaded photo successfully: ${photo.toString()}');
    await documentRef.setData(photo.toMap(), merge: true);
    photoUploaded(photo);
  }
}

deletePhoto(Photo photo, Function photoDeleted) async {
  if (photo.image != null) {
    StorageReference storageReference =
        await FirebaseStorage.instance.getReferenceFromUrl(photo.image);

    print(storageReference.path);

    await storageReference.delete();

    print('image deleted');
  }

  await Firestore.instance.collection('Collection').document(photo.id).delete();
  photoDeleted(photo);
}
