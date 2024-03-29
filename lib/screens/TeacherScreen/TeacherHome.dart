import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/constants.dart';
import 'package:demo/screens/TeacherScreen/AddStudentToClass.dart';
import 'package:demo/screens/TeacherScreen/MakeNewClass.dart';
import 'package:demo/screens/TeacherScreen/TeacherProfile.dart';
import 'package:demo/screens/TeacherScreen/TeacherReusable.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AuthenticationScreens/LoginTeacher.dart';
import '../IntroScreen.dart';

BuildContext tempContext;

class TeacherHome extends StatefulWidget {
  static const String id = "TeacherHome";
  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

final _firestore = FirebaseFirestore.instance;
List<AssignmentDetails> assignmentList = [];
List<AssignmentDetails> completedAssignment = [];
List<AssignmentDetails> assignedAssignment = [];

//List<classDetails> classList;
class _TeacherHomeState extends State<TeacherHome> {
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  //final primaryColor = Color(0xFF488fb1);
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
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
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    tempContext = context;
    List<Widget> card = [];
    try {
      card.add(HeadingText(text: "My Classes"));
      for (int j = 0; j < classList.length; j++) {
        card.add(ClassCard(
          path: classList[j].classId,
          className: classList[j].className,
          department: classList[j].dept,
          batch: classList[j].batch,
          context: context,
        ));
      }
    } catch (e) {
      print(e);
    }
    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: card,
        ),
        backgroundColor: kPrimaryColor,
        floatingActionButton: _getFAB(),
      ),
    );
  }

  Widget _getFAB() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, right: 15, top: 0, left: 0),
      child: SpeedDial(
        overlayColor: Colors.transparent,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22),
        backgroundColor: kPrimaryColor,
        visible: true,
        // curve: Curves.bounceIn,
        children: [
          // FAB 1
          SpeedDialChild(
            child: Icon(Icons.add_circle_outline, color: kPrimaryColor),
            onTap: () {
              Navigator.push(
                  tempContext,
                  MaterialPageRoute(
                    builder: (context) => MakeNewClass(),
                  ));
            },
            label: 'Add Class',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: kPrimaryColor,
          ),
          // FAB 2
          SpeedDialChild(
              child: Icon(Icons.person, color: kPrimaryColor),
              onTap: () {
                // Navigator.push(
                //     tempContext,
                //     MaterialPageRoute(
                //       builder: (context) => TeacherProfile(),
                //     ));
              },
              label: 'Profile',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: kPrimaryColor),
          SpeedDialChild(
              child: Icon(Icons.logout, color: kPrimaryColor),
              onTap: () async {
                SharedPreferences sharedPref =
                    await SharedPreferences.getInstance();
                await sharedPref.clear();
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IntroScreen(),
                    ));
              },
              label: 'Log Out',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: kPrimaryColor),
        ],
      ),
    );
  }
}

String convert(String a, String b) {
  // 19-12-2018 => 2018-12-19
  String one, two, three;
  one = a[6] + a[7] + a[8] + a[9];
  two = a[3] + a[4];
  three = a[0] + a[1];

  String s1 = one + '-' + two + '-' + three;
  s1 = s1 + ' ' + b + ':' + '00' + '.' + '000';
  return s1;
}

Future<void> getAssignmentData(String classID, String className) async {
  assignmentList = await fetchAllAssignments(classID, className) as List;
  assignedAssignment.clear();
  completedAssignment.clear();
  print(assignmentList);
  try {
    for (int i = 0; i < assignmentList.length; i++) {
      String s1 = assignmentList[i].startDate;
      String s2 = assignmentList[i].startTime;
      s1 = convert(s1, s2);
      DateTime d1 = DateTime.parse(s1);
      s1 = assignmentList[i].endDate;
      s2 = assignmentList[i].endTime;
      s1 = convert(s1, s2);
      DateTime d2 = DateTime.parse(s1);
      DateTime d = DateTime.now();
      int difference = d2.difference(d1).inHours;
      String duration = "";
      if (difference != 0) {
        duration += difference.toString();
        duration += 'h ';
      }
      difference = d2.difference(d1).inMinutes;
      difference = difference % 60;
      if (difference != 0) {
        duration += difference.toString();
        duration += 'min';
      }
      print(duration);
      assignmentList[i].duration = duration;
      if (d.isBefore(d2)) {
        assignedAssignment.add(assignmentList[i]);
      } else {
        completedAssignment.add(assignmentList[i]);
      }
    }
  } catch (e) {
    print(e);
  }
  print(assignedAssignment);
  print(completedAssignment);
}

Future<List<AssignmentDetails>> fetchAllAssignments(
    String classID, String className) async {
  List<AssignmentDetails> assignments = [];
  List<String> contact = [];
  QuerySnapshot q = await _firestore
      .collection('Classes')
      .doc(classID)
      .collection('Student_List')
      .get();

  q.docs.forEach((element) {
    contact.add(element['Contact']);
  });

  QuerySnapshot querySnapshot = await _firestore
      .collection('Classes')
      .doc(classID)
      .collection('Assignment_List')
      .get();
  querySnapshot.docs.forEach((element) {
    AssignmentDetails obj = AssignmentDetails();
    obj.assignmentName = element["Name"];
    obj.startTime = element["Start Time"];
    obj.startDate = element["Start Date"];
    obj.endTime = element["End Time"];
    obj.endDate = element["End Date"];
    obj.password = element["Password"];
    obj.link = element["Download Link"];
    obj.studentContact = contact;
    obj.start = DateTime.parse(element["Start DateTime"]);
    obj.end = DateTime.parse(element["End DateTime"]);
    print(element["Name"]);
    assignments.add(obj);
  });
  return assignments;
}

class AssignmentDetails {
  String assignmentName, startTime, startDate, endTime, endDate;
  String password, link, duration;
  DateTime start, end;
  List<String> studentContact = [];
}
