import 'dart:io';
import 'dart:math';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:holy_money/pages/earnings.dart';
import 'package:holy_money/pages/expenses.dart';
import 'package:image_picker/image_picker.dart';
import 'package:holy_money/models/user.dart';
import 'package:holy_money/pages/create_account.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection('users');
final organizationsRef = Firestore.instance.collection('organizations');
final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final notificationsRef = Firestore.instance.collection('notifications');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final feedRef = Firestore.instance.collection('feed');
final DateTime timestamp = DateTime.now();
User currentUser;
final StorageReference storageRef = FirebaseStorage.instance.ref();



class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  final String logoFile = 'assets/images/logo.svg';
  PageController pageController;
  int pageIndex = 0;
  double screenHeight = 250.0;
  File imageFile;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() { 
    super.initState();
    // Init Page Controller
    pageController = PageController();
    // Listen user login
    googleSignIn.onCurrentUserChanged.listen((account){
      handleLogin(account);
    }, onError: (err){
      print('Signin error! $err');
    });
    // Reauthenticate user if signed in previously
    googleSignIn.signInSilently(suppressErrors: false)
      .then((account){
        handleLogin(account);
      }).catchError((err){
        print('Reauthentication error!: $err');
    });
  }

  @override
  void dispose() { 
    pageController.dispose();
    super.dispose();
  }

  changePage(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  Scaffold authScreen(){
    void postModal(){
      showModalBottomSheet(context: context, builder: (context){
        return Container(
          height: 500.0,
          child: Column(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: IconButton(
                        icon: Icon(Feather.chevron_down, size: 30.0, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/create.gif"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15.0),
              ),
              ListTile(
                leading: Icon(Feather.camera, size: 50.0, color: Colors.blue,),
                title: Text("take photo", style: TextStyle(fontFamily: "Waxe", fontWeight: FontWeight.w600),),
                subtitle: Text("capture with camera & create post", style: TextStyle(fontFamily: "Waxe"),),
                onTap: takePhoto,
              ),
              ListTile(
                leading: Icon(Feather.image, size: 50.0, color: Colors.purple,),
                title: Text("photo from gallery", style: TextStyle(fontFamily: "Waxe", fontWeight: FontWeight.w600),),
                subtitle: Text("create post from gallery", style: TextStyle(fontFamily: "Waxe"),),
                onTap: takeCamera,
              ),
              ListTile(
                leading: Icon(Feather.video, size: 50.0, color: Colors.green,),
                title: Text("record video", style: TextStyle(fontFamily: "Waxe", fontWeight: FontWeight.w600),),
                subtitle: Text("record video with camera & create post", style: TextStyle(fontFamily: "Waxe"),),
                onTap: takeCamera,
              ),
              ListTile(
                leading: Icon(Feather.folder_plus, size: 50.0, color: Colors.redAccent,),
                title: Text("video from gallery", style: TextStyle(fontFamily: "Waxe", fontWeight: FontWeight.w600),),
                subtitle: Text("add video post from gallery", style: TextStyle(fontFamily: "Waxe"),),
                onTap: takeCamera,
              ),
            ],
          )
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0)
        ),
      ),
    );
  }

    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Expenses(),
          Earnings(),
        ],
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: changePage(pageIndex),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: postModal,
        child: Icon(Feather.plus),
        backgroundColor: Theme.of(context).accentColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BubbleBottomBar(
        opacity: .09,
        //backgroundColor: Theme.of(context).accentColor,
        currentIndex: pageIndex,
        onTap: (pageIndex){
          pageController.animateToPage(
            pageIndex,
            duration: Duration(milliseconds: 270),
            curve: Curves.ease
          );
          changePage(pageIndex);
        },
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        elevation: 15,
        fabLocation: BubbleBottomBarFabLocation.end, //new
        hasNotch: true, //new
        hasInk: true, //new, gives a cute ink effect
        inkColor: Colors.black12, //optional, uses theme color if not specified
        items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(
              backgroundColor: Colors.blue,
              icon: Icon(Icons.money_off, color: Colors.black,),
              activeIcon: Icon(Icons.money_off, color: Colors.blue,),
              title: Text("expenses", style: TextStyle(fontFamily: "MontThin"),)
            ),
            BubbleBottomBarItem(
              backgroundColor: Colors.indigo,
              icon: Icon(Icons.offline_bolt, color: Colors.black,),
              activeIcon: Icon(Icons.offline_bolt, color: Colors.indigo,),
              title: Text("earnings", style: TextStyle(fontFamily: "MontThin"),)
            ),
            BubbleBottomBarItem(
              backgroundColor: Colors.green,
              icon: Icon(Icons.menu, color: Colors.black,),
              activeIcon: Icon(Icons.menu, color: Colors.green,),
              title: Text("menu", style: TextStyle(fontFamily: "MontThin"),)
            ),
        ],
      ),
    );
  }

  takePhoto() async{
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960
    );
    setState(() {
      this.imageFile = imageFile;
    });
  }

  takeCamera() async{
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 675,
      maxWidth: 960
    );
    setState(() {
      this.imageFile = imageFile;
    });
  }

  login(){
    googleSignIn.signIn();
  }

  logout(){
    googleSignIn.signOut();
  }

  handleLogin(GoogleSignInAccount account) async {
    if(account != null){
        print(account);
        await createUser();
        setState(() {
          isAuth = true;
        });
        configPushNotfication();
      } else {
        setState(() {
          isAuth = false;
        });
    }
  }

  configPushNotfication(){
    final GoogleSignInAccount user = googleSignIn.currentUser;
    if(Platform.isIOS) getIOSPermission();
    _firebaseMessaging.getToken().then((token){
      usersRef
        .document(user.id)
        .updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print("OnLaunch Notification");
      },
      onResume: (Map<String, dynamic> message) async {
        print("OnResume Notification");
      },
      onMessage: (Map<String, dynamic> message) async {
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if(recipientId == user.id){
          SnackBar snackbar = SnackBar(content: Text(body, overflow: TextOverflow.ellipsis,));
          _scaffoldKey.currentState.showSnackBar(snackbar);
        }
      },
    );
  }

  getIOSPermission(){
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings){
      print("Settings registered! $settings");
    });
  }

  createUser() async{
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    if (!doc.exists){
      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));
      doc = await usersRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
  }

  Scaffold unAuthScreen(){
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              logoFile,
              //color: Colors.black,
            ),
            Text('HolyMoney', style: TextStyle(fontFamily: 'Mont', fontSize: 25,),),
            GestureDetector(
              child: Container(
                margin: EdgeInsets.all(50.0),
                height: 40.0,
                width: 180.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/google_signin_button.png"),
                    fit: BoxFit.cover
                  ),
                ),
              ),
              onTap: login,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? authScreen() :  unAuthScreen();
  }
}
