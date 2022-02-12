import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//  my imports
import 'app.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'clinicun',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        // primaryColor: Colors.teal,
        primarySwatch: Colors.teal,
      ),
      home: CheckAuth(),
    );
  }
}

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  var role = "patient";
  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token != null) {
      setState(() {
        var user = jsonDecode(localStorage.getString('user')!);
        role = user['role'];
        isAuth = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isAuth) {
      switch (role) {
        case "patient":
          child = DashboardUserScreen();
          break;
        case "doctor":
          child = DashboardDoctorScreen();
          break;
        default:
          child = DashboardAdminScreen();
          break;
      }
    } else {
      child = LoginScreen();
    }
    return Scaffold(
      body: child,
    );
  }
}
