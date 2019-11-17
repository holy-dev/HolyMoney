import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String displayName;
  final String username;
  final String email;
  final String photoUrl;
  final String bio;
  final String phone;
  final String dob;

  User({
    this.id,
    this.displayName,
    this.username,
    this.email,
    this.photoUrl,
    this.bio,
    this.phone,
    this.dob,
  });

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      id: doc['id'],
      displayName: doc['displayName'],
      username: doc['username'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      bio: doc['bio'],
      phone: doc['phone'],
      dob: doc['dob'],
    );
  }
}
