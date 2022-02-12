import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/link.dart';
//  my imports
import '../../../app.dart';

class HomeAdminScreen extends StatefulWidget {
  final Future<List<User>> users;

  const HomeAdminScreen({Key? key, required this.users}) : super(key: key);
  @override
  _HomeAdminScreenState createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  var name;
  var email;
  var role;

  @override
  void initState() {
    _loadDoctorData();
    super.initState();
  }

  _loadDoctorData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var doctor = jsonDecode(localStorage.getString('user')!);

    if (doctor != null) {
      setState(() {
        name = doctor['name'];
        email = doctor['email'];
        role = doctor['role'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Expanded(
          child: Link(
              uri: Uri.parse('http://clinicunapp.herokuapp.com/public/'),
              target: LinkTarget.self,
              builder: (context, followLink) {
                return RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Admin dont\' have interaction with app go to : ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'Dashboard',
                      style: TextStyle(
                        color: Colors.teal,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = followLink,
                    ),
                  ]),
                );
              }),
        ),
      ),
    );
  }
}
