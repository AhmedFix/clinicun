import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//  my imports
import '../../../app.dart';

class HomeDoctorScreen extends StatefulWidget {
  final Future<List<User>> users;

  const HomeDoctorScreen({Key? key, required this.users}) : super(key: key);
  @override
  _HomeDoctorScreenState createState() => _HomeDoctorScreenState();
}

class _HomeDoctorScreenState extends State<HomeDoctorScreen> {
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
        child: ItemUserWidget(users: widget.users),
      ),
    );
  }
}
