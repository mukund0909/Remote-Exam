import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/screens/StudentScreen/StudentHome.dart';
import 'package:demo/screens/TeacherScreen/TeacherHome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../constants.dart';
import '../AuthenticationScreens/LoginTeacher.dart';

class MakeNewClass extends StatefulWidget {
  static const String id = "MakeNewClass";
  @override
  State<MakeNewClass> createState() => _MakeNewClassState();
}

class _MakeNewClassState extends State<MakeNewClass> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  bool showSpinner = false;
  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  String _classname, _batch, _department;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: 75.0,
                    width: 75.0,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                  SizedBox(height: 30.0),
                  Text(
                    "Class Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40.0,
                      color: kPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 0),
                    child: Container(
                      child: TextField(
                        onChanged: (value) {
                          _classname = value;
                        },
                        cursorColor: kPrimaryColor,
                        style: TextStyle(color: Colors.grey.shade600),
                        decoration: InputDecoration(
                          labelText: "Class Name",
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade700),
                          ),
                          hintText: "Enter class name",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 0),
                    child: Container(
                      child: TextField(
                        onChanged: (value) {
                          _batch = value;
                        },
                        cursorColor: kPrimaryColor,
                        style: TextStyle(color: Colors.grey.shade600),
                        decoration: InputDecoration(
                          labelText: "Batch",
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade700),
                          ),
                          hintText: "Enter batch",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 0),
                    child: Container(
                      child: TextField(
                        onChanged: (value) {
                          _department = value;
                        },
                        keyboardType: TextInputType.text,
                        cursorColor: kPrimaryColor,
                        style: TextStyle(color: Colors.grey.shade600),
                        decoration: InputDecoration(
                          labelText: "Department",
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade700),
                          ),
                          hintText: "Enter department",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50.0, 40.0, 50.0, 0),
                    child: GestureDetector(
                      onTap: () async {
                        // Navigator.pushNamed(context, StudentHome.id);
                        setState(() {
                          showSpinner = true;
                        });
                        if (_classname != null &&
                            _batch != null &&
                            _department != null) {
                          _firestore
                              .collection("AUTH_DATA")
                              .doc("TEACHER")
                              .collection(FirebaseAuth.instance.currentUser.uid)
                              .doc("Class_List")
                              .collection("Classes")
                              .doc(FirebaseAuth.instance.currentUser.uid +
                                  _classname)
                              .set({
                            "Class Name": _classname,
                            "Batch": _batch,
                            "Department": _department,
                            "Class id": FirebaseAuth.instance.currentUser.uid +
                                _classname,
                          });
                          _firestore
                              .collection("Classes")
                              .doc(FirebaseAuth.instance.currentUser.uid +
                                  _classname)
                              .collection("Class_Details")
                              .doc("Info")
                              .set({
                            "Class Name": _classname,
                            "Batch": _batch,
                            "Department": _department,
                            "Class id": FirebaseAuth.instance.currentUser.uid +
                                _classname,
                          });
                          DocumentSnapshot document = await _firestore
                              .collection("AUTH_DATA")
                              .doc("TEACHER")
                              .collection(FirebaseAuth.instance.currentUser.uid)
                              .doc("Teacher_Details")
                              .get();
                          _firestore
                              .collection("Classes")
                              .doc(FirebaseAuth.instance.currentUser.uid +
                                  _classname)
                              .collection("Class_Details")
                              .doc("Teacher_Details")
                              .set({
                            "Teacher_id": FirebaseAuth.instance.currentUser.uid,
                            "Contact": document["Contact"],
                            "Department": document["Department"],
                            "Email": document["Email"],
                            "Name": document["Name"],
                          });
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('All Fields are Mandatory'),
                          ));
                        }
                        try {
                          await getData().then((value) => null);
                          setState(() {
                            showSpinner = false;
                          });
                        } catch (e) {
                          print(e);
                          setState(() {
                            showSpinner = false;
                          });
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Failed to load class'),
                          ));
                        }
                        //print(classList);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    TeacherHome()));
                      },
                      child: Container(
                        height: buttonHeight,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Create Class",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
