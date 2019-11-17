import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:holy_money/pages/home.dart';

header(context, { bool isAppTitle = false, String appTitle, bool isAccount = false }) {
  final String logoFile = 'assets/images/logo.svg';
  
  signout(){
    googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0.0,
    //centerTitle: true,
    automaticallyImplyLeading: false,
    leading: Container(
      margin: EdgeInsets.all(10.0),
      child: SvgPicture.asset(
        logoFile,
        // color: Colors.black,
      ),
    ),
    title: Text(
      isAppTitle ? appTitle : "seamify",
      style: TextStyle(
        color: Colors.black,
        fontFamily: "MontMed",
        fontSize: 25.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    primary: true,
    actions: <Widget>[
      Container(
        alignment: Alignment.center,
        child: GestureDetector(
          // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(currentUser.id))),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
          ),
        ),
      ),
      IconButton(
        icon: Icon(Feather.log_out),
        onPressed: signout,
      )
    ],
  );
}
