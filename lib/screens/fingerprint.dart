import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:private_photo_album/screens/login.dart';
import 'package:private_photo_album/screens/photoGallery.dart';

class FingerPrint extends StatelessWidget {
  final LocalAuthentication localAuth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () async {
          bool weCanCheckBiometrics = await localAuth.canCheckBiometrics;
          
          if(weCanCheckBiometrics){
            bool authenicated = await localAuth.authenticateWithBiometrics(
              localizedReason: 'Authenticated to Private Photo Album'
            );
            
            if(authenicated) {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => PhotoGallery(),
                ),
              );
            }
          } 
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(
              Icons.fingerprint,
              size: 124.0,
            ),
            Text(
              'Touch to Login',
              style: GoogleFonts.passionOne(
                fontSize: 64.0,
              ),
              textAlign: TextAlign.center,
            ),
            ButtonTheme(
              minWidth: 200,
              child: RaisedButton(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Back',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
              ),
            ),
          ]
        ),
      ), 
    );
  }
}