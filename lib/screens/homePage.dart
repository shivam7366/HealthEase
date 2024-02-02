import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:healthcare/firestore-data/notificationList.dart';
import 'package:healthcare/model/cardModel.dart';
import 'package:healthcare/carouselSlider.dart';
import 'package:healthcare/screens/doctor/doctorMainPage.dart';
import 'package:healthcare/screens/exploreList.dart';
import 'package:healthcare/firestore-data/searchList.dart';
import 'package:healthcare/firestore-data/topRatedList.dart';
import 'package:healthcare/screens/signIn.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _doctorName = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  Future<void> _getUser() async {
    user = _auth.currentUser;
  }

  Future _signOut() async {
    await _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
    _getUser();
    _doctorName = new TextEditingController();
  }

  @override
  void dispose() {
    _doctorName.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    String? role = _getUserRole().toString();
    String? _message;
    DateTime now = DateTime.now();
    String _currentHour = DateFormat('kk').format(now);
    int hour = int.parse(_currentHour);

    setState(
      () {
        if (hour >= 5 && hour < 12) {
          _message = 'Good Morning';
        } else if (hour >= 12 && hour <= 17) {
          _message = 'Good Afternoon';
        } else {
          _message = 'Good Evening';
        }
      },
    );

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      primary: Colors.black87,
      minimumSize: Size(88, 36),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[Container()],
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          padding: EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                //width: MediaQuery.of(context).size.width/1.3,
                alignment: Alignment.center,
                child: Text(
                  _message.toString(),
                  style: GoogleFonts.lato(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                width: 55,
              ),
              IconButton(
                splashRadius: 20,
                icon: Icon(Icons.notifications_active),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (contex) => NotificationList()));
                },
              ),
            ],
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return false;
          },
          child: ListView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              role == 'patient'
                  ? Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 20, bottom: 10),
                          child: Text(
                            role == 'patient'
                                ? "Hello " + user!.displayName.toString()
                                : "Hello Dr. " + user!.displayName.toString(),
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 20, bottom: 25),
                          child: Text(
                            "Let's Find Your\nDoctor",
                            style: GoogleFonts.lato(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 25),
                          child: TextFormField(
                            textInputAction: TextInputAction.search,
                            controller: _doctorName,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 20, top: 10, bottom: 10),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'Search doctor',
                              hintStyle: GoogleFonts.lato(
                                color: Colors.black26,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                              suffixIcon: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue[900]?.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  iconSize: 20,
                                  splashRadius: 20,
                                  color: Colors.white,
                                  icon: Icon(TablerIcons.search),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                            onFieldSubmitted: (String value) {
                              setState(
                                () {
                                  value.length == 0
                                      ? Container()
                                      : Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SearchList(
                                              searchKey: value,
                                            ),
                                          ),
                                        );
                                },
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 23, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "We care for you",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Carouselslider(),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Specialists",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        Container(
                          height: 150,
                          padding: EdgeInsets.only(top: 14),
                          child: ListView.builder(
                            physics: ClampingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            itemCount: cards.length,
                            itemBuilder: (context, index) {
                              //print("images path: ${cards[index].cardImage.toString()}");
                              return Container(
                                margin: EdgeInsets.only(right: 14),
                                height: 150,
                                width: 140,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Color(cards[index].cardBackground),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromRGBO(
                                            189, 189, 189, 1),
                                        blurRadius: 4.0,
                                        spreadRadius: 0.0,
                                        offset: Offset(3, 3),
                                      ),
                                    ]
                                    // image: DecorationImage(
                                    //   image: AssetImage(cards[index].cardImage),
                                    //   fit: BoxFit.fill,
                                    // ),
                                    ),
                                // ignore: deprecated_member_use
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ExploreList(
                                                type: cards[index].doctor,
                                              )),
                                    );
                                  },
                                  style: flatButtonStyle,
                                  // shape: new RoundedRectangleBorder(
                                  //     borderRadius: new BorderRadius.circular(20)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Container(
                                        child: CircleAvatar(
                                            backgroundColor: Color.fromARGB(
                                                255, 255, 255, 255),
                                            radius: 29,
                                            child: Icon(
                                              cards[index].cardIcon,
                                              size: 26,
                                              color: Color(
                                                  cards[index].cardBackground),
                                            )),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        alignment: Alignment.bottomCenter,
                                        child: Text(
                                          cards[index].doctor,
                                          style: GoogleFonts.lato(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Top Rated",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: TopRatedList(),
                          // child: Text('TopRatedList*()'),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome Dr. " + user!.displayName.toString(),
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "You are logged in as a Doctor",
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorMainPage(),
                                ),
                              );
                            },
                            child: Text('Go to Doctor Main Page'),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _signOut();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignIn(),
                                ),
                              );
                            },
                            child: Text('Sign Out'),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
