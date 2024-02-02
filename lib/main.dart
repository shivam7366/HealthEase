import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthcare/screens/doctor/doctorDetailForm.dart';
import 'package:healthcare/screens/doctor/doctorMainPage.dart';
import 'package:healthcare/screens/homePage.dart';
import 'package:healthcare/screens/myAppointments.dart';
import 'package:healthcare/screens/skip.dart';
import 'package:healthcare/screens/firebaseAuth.dart';
import 'package:healthcare/mainPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare/screens/userProfile.dart';
import 'package:healthcare/screens/doctorProfile.dart';
import 'package:healthcare/screens/doctor/doctorMainPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAHhWddb5_Yp2N6wNX_mvlIw8qi10UuJLY",
          appId: "1:394779846670:android:1daa1d2ae5a78d7549745f",
          messagingSenderId: "394779846670",
          projectId: "healthcare-8030a"));
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //  MyApp({super.key});
  FirebaseAuth? _auth = FirebaseAuth.instance;
  User? user;

  Future<void> _getUser() async {
    user = _auth!.currentUser;
  }

  Future<String?> _getUserRole() async {
    String? role;
    String? userId = _auth!.currentUser?.uid;

    if (userId != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        role = userSnapshot.get('role');
      }
    }

    return role;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _getUser();
    Future<String?> role = _getUserRole();
    return MaterialApp(
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => user == null
            ? Skip()
            : role == 'patient'
                ? HomePage()
                : DoctorMainPage(),
        '/login': (context) => FireBaseAuth(),
        '/patientHome': (context) => MainPage(),
        '/MyAppointments': (context) => MyAppointments(),
        '/doctorHome': (context) => DoctorMainPage(),
        '/doctorDetailForm': (context) => DoctorDetailForm(),
      },
      theme: ThemeData(brightness: Brightness.light),
      debugShowCheckedModeBanner: false,
    );
  }
}
