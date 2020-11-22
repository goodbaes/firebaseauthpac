library firebaseauth;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User> _user = FirebaseAuth.instance.currentUser.obs;
  User get user => _user.value;

  @override
  void onInit() {
    _user.bindStream(_auth.authStateChanges());
  }

  void createUser({String name, String email, String password}) async {
    try {
      UserCredential _authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      UserModel _user =
          UserModel(id: _authResult.user.uid, name: name, email: email);
      Get.find<UserController>().createnewUser(_user);
    } catch (e) {
      Get.snackbar('Create Error', e.message,
          snackStyle: SnackStyle.GROUNDED,
          backgroundColor: Colors.blue[50],
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void login({String email, String password}) async {
    try {
      UserCredential _authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      Get.find<UserController>().getUser(_authResult.user.uid);
    } catch (e) {
      Get.snackbar('Login Error', e.message,
          snackStyle: SnackStyle.GROUNDED,
          backgroundColor: Colors.blue[50],
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void singOut() async {
    try {
      _auth.signOut();
      Get.find<UserController>().clear();
    } catch (e) {
      Get.snackbar('SingOut Error', e.message,
          snackStyle: SnackStyle.GROUNDED,
          backgroundColor: Colors.blue[50],
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

class UserController extends GetxController {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<UserModel> _userModel = UserModel().obs;
  UserModel get user => _userModel.value;
  set user(UserModel value) => this._userModel.value = value;

  void clear() {
    _userModel.value = UserModel();
  }

  void createnewUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set({'name': user.name, 'email': user.email});
      getUser(user.id);
      Get.back();
    } catch (e) {}
  }

  void getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      user = UserModel.fromDocumentSnapshot(doc);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void onInit() {
    try {
      Get.find<AuthController>().user.uid != null
          ? getUser(Get.find<AuthController>().user.uid)
          : print('reg');
    } catch (e) {}
  }
}

class UserModel {
  String id;
  String name;
  String email;
  UserModel({this.id, this.name, this.email});

  UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    name = doc["name"];
    email = doc["email"];
  }
}
