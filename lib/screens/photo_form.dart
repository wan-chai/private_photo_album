import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:private_photo_album/api/photo_api.dart';
import 'package:private_photo_album/model/photo.dart';
import 'package:private_photo_album/notifier/photo_notifier.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PhotoForm extends StatefulWidget {
  final bool isUpdating;

  PhotoForm({@required this.isUpdating});

  @override
  _PhotoFormState createState() => _PhotoFormState();
}

class _PhotoFormState extends State<PhotoForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Photo _currentPhoto;
  String _imageUrl;
  File _imageFile;
   String locGPS = "";
 
  @override
  void initState() {
    super.initState();
    PhotoNotifier photoNotifier = Provider.of<PhotoNotifier>(context, listen: false);

    if (photoNotifier.currentPhoto != null) {
      _currentPhoto = photoNotifier.currentPhoto;
    } else {
      _currentPhoto = Photo();
    }

    _imageUrl = _currentPhoto.image;
  }

  _showImage() {
    if (_imageFile == null && _imageUrl == null) {
      return Text("image placeholder");
    } else if (_imageFile != null) {
      print('showing image from local file');

      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.file(
            _imageFile,
            fit: BoxFit.cover,
            height: 250,
          ),
          FlatButton(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              'Change Image',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
            ),
            onPressed: () => _chooseImagePicker(),
          )
        ],
      );
    } else if (_imageUrl != null) {
      print('showing image from url');

      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.network(
            _imageUrl,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            height: 250,
          ),
          FlatButton(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              'Change Image',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
            ),
            onPressed: () => _chooseImagePicker(),
          )
        ],
      );
    }
  }

Future<void> openCamera(BuildContext context) async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 400);

    if (imageFile != null) {
      this.setState(() {
        _imageFile = imageFile;
      });
    }
    Navigator.of(context).pop();
}

Future<void> openGallery(BuildContext context) async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 400);

    if (imageFile != null) {
      this.setState(() {
        _imageFile = imageFile;
      });
    }
    Navigator.of(context).pop();
}

//choose eather pick imaage from camera or gallary
Future<void> _chooseImagePicker() {
  return showDialog(context: context,builder:(BuildContext context){
    return AlertDialog(
      title: Text('Photo from ?'),
      content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          GestureDetector(
            child: Text('Camera'),
            onTap: () {
              openCamera(context);
              },
          ),
          Padding(padding: EdgeInsets.only(top:8)),
          GestureDetector(
            child: Text('Gallery'),
            onTap: () {
              openGallery(context);
              },
          ),
        ],
      ),
      ),
    );
  }); 
}

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Description'),
      initialValue: _currentPhoto.description,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Description is required';
        }

        return null;
      },
      onSaved: (String value) {
        _currentPhoto.description = value;
      },
    );
  }

  Widget _buildGpsLocationFieldUpdating() {
    return Text( 'GPS Location : ' + _currentPhoto.gpsLocation);
  }

  Widget _buildGpsLocationField() {
    return Text(
        _currentPhoto.gpsLocation = locGPS
    );
  }

  void _getCurrentLocation() async {
    final position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);

    setState(() {
      locGPS = "${position.latitude}, ${position.longitude}";
    });
  }

  _onPhotoUploaded(Photo photo) {
    PhotoNotifier photoNotifier = Provider.of<PhotoNotifier>(context, listen: false);
    photoNotifier.addPhoto(photo);
    Navigator.pop(context);
  }

  _savePhoto() {
    print('savePhoto Called');
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    print('form saved');

    uploadPhotoAndImage(_currentPhoto, widget.isUpdating, _imageFile, _onPhotoUploaded);

    print("description: ${_currentPhoto.description}");
    print("gpsLocation: ${_currentPhoto.gpsLocation}");
    print("_imageFile ${_imageFile.toString()}");
    print("_imageUrl $_imageUrl");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Photo Form')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          //autovalidate: true,
          child: Column(children: <Widget>[
            _showImage(),
            SizedBox(height: 16),
            Text(
              widget.isUpdating ? "Edit Photo" : "Create Photo",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 16),
            _imageFile == null && _imageUrl == null
                ? ButtonTheme(
                    child: RaisedButton(
                      onPressed: () => _chooseImagePicker(),
                      child: Text(
                        'Add Image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : SizedBox(height: 0),
            widget.isUpdating ? _buildGpsLocationFieldUpdating() : _buildGpsLocationField(),
            widget.isUpdating ? SizedBox(height: 0) : 
            ButtonTheme(
                  child: RaisedButton(
                    child: Text('Add GPS Location', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      _getCurrentLocation();
                    },
                  ),
                ),
            SizedBox(height: 15), 
            _buildDescriptionField(), 
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          _savePhoto();
        },
        child: Icon(Icons.save),
        foregroundColor: Colors.white,
      ),
    );
  }
}
