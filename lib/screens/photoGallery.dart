import 'package:private_photo_album/api/photo_api.dart';
import 'package:private_photo_album/notifier/auth_notifier.dart';
import 'package:private_photo_album/notifier/photo_notifier.dart';
import 'package:private_photo_album/screens/detail.dart';
import 'package:private_photo_album/screens/photo_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhotoGallery extends StatefulWidget {
  @override
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  @override
  void initState() {
    PhotoNotifier photoNotifier = Provider.of<PhotoNotifier>(context, listen: false);
    getPhotos(photoNotifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    PhotoNotifier photoNotifier = Provider.of<PhotoNotifier>(context);

    Future<void> _refreshList() async {
      getPhotos(photoNotifier);
    }

    print("building PhotoGallery");
    return Scaffold(
      appBar: AppBar(
        title: Text("Private Photo Album",
        ),
        actions: <Widget>[
          // action button
          FlatButton(
            onPressed: () => signout(authNotifier),
            child: Text(
              "Logout",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
      body: new RefreshIndicator(
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Image.network(
                photoNotifier.photoList[index].image != null
                    ? photoNotifier.photoList[index].image
                    : 'https://www.testingxperts.com/wp-content/uploads/2019/02/placeholder-img.jpg',
                width: 120,
                fit: BoxFit.fitWidth,
              ),
              title: Text(photoNotifier.photoList[index].description),
              subtitle: Text(photoNotifier.photoList[index].gpsLocation),
              onTap: () {
                photoNotifier.currentPhoto = photoNotifier.photoList[index];
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                  return PhotoDetail();
                }));
              },
            );
          },
          itemCount: photoNotifier.photoList.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              color: Colors.black,
            );
          },
        ),
        onRefresh: _refreshList,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          photoNotifier.currentPhoto = null;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
              return PhotoForm(
                isUpdating: false,
              );
            }),
          );
        },
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
      ),
    );
  }
}
