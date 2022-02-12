import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//  my imports
import '../../../app.dart';

class DrawerDoctorItem {
  String title;
  IconData icon;
  DrawerDoctorItem(this.title, this.icon);
}

class DashboardDoctorScreen extends StatefulWidget {
  final doctordrawerItems = [
    new DrawerItem("Home", Icons.home),
    new DrawerItem("Profile", Icons.person_outline),
  ];

  @override
  State<StatefulWidget> createState() {
    return new DashboardDoctorScreenState();
  }
}

class DashboardDoctorScreenState extends State<DashboardDoctorScreen> {
  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return HomeDoctorScreen(
          users: Network.fetchUsersRequest(),
        );
      case 1:
        return ProfileDoctorScreen();

      default:
        return Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  var id;
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
        id = doctor['id'];
        name = doctor['name'];
        email = doctor['email'];
        role = doctor['role'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerOptions = [];
    for (var i = 0; i < widget.doctordrawerItems.length; i++) {
      var d = widget.doctordrawerItems[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(d.icon),
        title: new Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: new Scaffold(
        drawer: new Drawer(
          child: SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.teal,
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage("assets/images/doctor.jpg"),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "$name",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "$email",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    )),
                Column(children: drawerOptions),
                SizedBox(height: MediaQuery.of(context).size.height * 0.53),
                ListTile(
                  leading: new Icon(Icons.exit_to_app),
                  title: new Text('logout'),
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) {
                        return CustomDialog(
                          icon: Icons.error,
                          title: "Logout",
                          content:
                              "Are you sure to log out, you will lose your locale data!",
                          positiveBtnText: "Yes",
                          negativeBtnText: "Cancel",
                          positiveBtnPressed: () {
                            logout();
                            Navigator.of(context).pop();
                          },
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          titleTextStyle: TextStyle(color: Colors.teal),
          iconTheme: IconThemeData(color: Colors.teal),
          centerTitle: true,
          title: Text(
            '$role Dashboard',
            style: TextStyle(color: Colors.teal),
          ),
          backgroundColor: Colors.white,
        ),
        body: _getDrawerItemWidget(_selectedDrawerIndex),
      ),
    );
  }

  void logout() async {
    var res = await Network().getData('/logout');
    var body = json.decode(res.body);
    if (res.statusCode == 200) {
      print(body);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      localStorage.remove('token');
      localStorage.remove('role');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }
}
