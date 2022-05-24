import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

final _firestore = FirebaseFirestore.instance;

class submitPDF extends StatefulWidget {
  static String id = "submitPDF";
  String classId = "", assignmentId = "";
  submitPDF(this.classId, this.assignmentId);

  @override
  State<submitPDF> createState() => _submitPDFState();
}

class _submitPDFState extends State<submitPDF> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: 75.0,
                    width: 75.0,
                    child: Image.asset('assets/file.png'),
                  ),
                  SizedBox(height: 30.0),
                  Text(
                    "Submit PDF",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40.0,
                      color: kPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My work',
                        style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0, 0),
                        child: GestureDetector(
                          onTap: () async {
                            FilePickerResult result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['jpg', 'pdf', 'doc'],
                            );
                          },
                          child: Material(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: SizedBox(
                                    height: 35,
                                    width: 170,
                                    child: Center(
                                      child: Text(
                                        "Create SHA",
                                        style: TextStyle(
                                          fontFamily: 'NotoSans',
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50.0, 40.0, 50.0, 0),
                    child: GestureDetector(
                      onTap: () {
                        _firestore
                            .collection("Classes")
                            .doc(widget.classId)
                            .collection("Assignment_List")
                            .doc(widget.assignmentId)
                            .collection('Submissions')
                            .doc(FirebaseAuth.instance.currentUser.uid)
                            .set({
                          "Name": FirebaseAuth.instance.currentUser.displayName,
                          "SHA": "yeh sha hai",
                          "Roll": "roll",
                          "Download Link": "downloadURL",
                        });
                      },
                      child: Container(
                        height: buttonHeight,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Submit",
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
