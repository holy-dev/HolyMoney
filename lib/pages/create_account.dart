import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:holy_money/models/user.dart';
import 'package:holy_money/pages/home.dart';
import 'package:masked_text_input_formatter/masked_text_input_formatter.dart';

//initializeDateFormatting("en_IN", null).then((_) => {});

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String username;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  User currentUser;
  TextEditingController usernameController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  String avatarUrl;
  TabController tabController;

  create() async {
    final form = _formKey.currentState;
    if (form.validate()){
      //form.save();
      final GoogleSignInAccount user = googleSignIn.currentUser;
      DocumentSnapshot doc = await usersRef.document(user.id).get();
      if (!doc.exists){
        usersRef.document(user.id).setData({
          "id": user.id,
          "displayName": user.displayName,
          "username": usernameController.text,
          "email": user.email,
          "photoUrl": user.photoUrl,
          "bio": "",
          "phone": phoneController.text,
          "dob": dobController.text,
          "timestamp": timestamp
        });
        await followersRef
          .document(user.id)
          .collection("userFollowers")
          .document(user.id)
          .setData({});
          
        doc = await usersRef.document(user.id).get();
      }
      currentUser = User.fromDocument(doc);
      SnackBar snackbar = SnackBar(
        content: Text("Welcome ${user.displayName}!")
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 3), (){
        Navigator.pop(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getuserDetails();
  }


  getuserDetails() {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    displayNameController.text = user.displayName;
    emailController.text = user.email;
    avatarUrl = user.photoUrl;
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 8,
          backgroundColor: Colors.white,
          title: Text("Create Account", style: TextStyle(color: Colors.black, fontFamily: "MontMed", fontSize: 20.0,),),
          centerTitle: true,
        ),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Form(
                            autovalidate: true,
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                Center(
                                  child: CircleAvatar(
                                    radius: 80.0,
                                    backgroundColor: Colors.blue,
                                    backgroundImage: CachedNetworkImageProvider(avatarUrl),
                                  ),
                                ),
                                TextFormField(
                                  controller: displayNameController,
                                  validator: (val){
                                    if (val.isEmpty){
                                      return "Name is required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Enter fullname",
                                    labelText: "Name"
                                  ),
                                  keyboardType: TextInputType.text,
                                ),
                                TextFormField(
                                  controller: emailController,
                                  validator: (val){
                                    if (val.isEmpty){
                                      return "Email is required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Enter email address",
                                    labelText: "Email"
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                TextFormField(
                                  controller: phoneController,
                                  validator: (val){
                                    if (val.isEmpty){
                                      return "Phone number is required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Enter phone number",
                                    labelText: "Phone Number"
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                                TextFormField(
                                  controller: usernameController,
                                  validator: (val){
                                    if (val.isEmpty){
                                      return "Username is required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Enter username",
                                    labelText: "Username"
                                  ),
                                ),
                                TextFormField(
                                  controller: dobController,
                                  inputFormatters: [
                                    MaskedTextInputFormatter(
                                      mask: 'dd-mm-yyyy',
                                      separator: '-'
                                    ),
                                  ],
                                  validator: (val){
                                    if (val.isEmpty){
                                      return "Date of birth is required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Enter date of birth",
                                    labelText: "Date of Birth"
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        RaisedButton(
                          elevation: 8,
                          child: Text("create", style: TextStyle(color: Colors.white),),
                          onPressed: create,
                          color: Theme.of(context).accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              child: Column(
                children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Form(
                        autovalidate: true,
                        key: _formKey,
                        child: TextFormField(
                          validator: (val){
                            if (val.trim().length < 4 || val.isEmpty){
                              return "Please use minimum 5 characters";
                            } else if (val.trim().length > 12){
                              return "Exceeded 12 characters";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (val) => username = val,
                          decoration: InputDecoration(
                            hintText: "Enter username"
                          ),
                        ),
                      ),
                    ),
                    RaisedButton.icon(
                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text("create", style: TextStyle(color: Colors.white),),
                      onPressed: create,
                      color: Colors.blue,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
