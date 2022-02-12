import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
//  my imports
import '../../../app.dart';

class UserListScreen extends StatefulWidget {
  final User user;

  const UserListScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  var name;
  var email;
  var role;
  @override
  void initState() {
    _loadDoctorData();
    tabController = TabController(initialIndex: 1, length: 3, vsync: this);
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
            builder: (context) => DashboardDoctorScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
          drawer: new Drawer(
            child: new Column(
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.red,
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
                        Text(
                          "$name",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          "$email",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.65),
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
                )
              ],
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            toolbarHeight: 110,
            leading: IconButton(
              padding: EdgeInsets.only(top: 4),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => DashboardDoctorScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.grey[600],
              ),
            ),
            titleTextStyle: TextStyle(color: Colors.red),
            iconTheme: IconThemeData(color: Colors.red),
            title: Container(
              padding: EdgeInsets.only(right: 16),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.user.name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0, right: 15),
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/doctor.jpg"),
                  maxRadius: 23,
                ),
              ),
            ],
            backgroundColor: Colors.white,
            bottom: TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.red,
              tabs: [
                Tab(icon: Icon(Icons.chat_rounded)),
                Tab(icon: Icon(Icons.question_answer_sharp)),
                Tab(icon: Icon(Icons.notifications))
              ],
              controller: tabController,
              indicatorColor: Colors.red,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              AnswersPage(
                question: Network.fetchAnswersRequest(widget.user.id),
                userId: widget.user.id,
              ),
              ChatPage(
                user: widget.user,
              ),
              StatusPage(
                user: widget.user,
              ),
            ],
            controller: tabController,
          )),
    );
  }

  void logout() async {
    var res = await Network().getData('/logout');
    var body = json.decode(res.body);
    if (res.statusCode == 200) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      localStorage.remove('token');
      localStorage.remove('role');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }
}
