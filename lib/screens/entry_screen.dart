import 'package:flutter/material.dart';
import 'package:project_prayer/screens/login_screen.dart';
import 'package:project_prayer/screens/signup_screen.dart';

class EntryScreen extends StatefulWidget {
  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  int pageIndex = 0;
  List<Widget> pages = [LoginScreen(), SignupScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 40.0,),
          Row(
            children: <Widget>[
              Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    pageIndex = 0;
                  });
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: pageIndex == 0 ? FontWeight.bold
                          : FontWeight.w400,
                      decoration: pageIndex == 0 ? TextDecoration.underline
                          : TextDecoration.none
                  ),
                ),
              ),
              SizedBox(width: 40.0,),
              GestureDetector(
                onTap: (){
                  setState(() {
                    pageIndex = 1;
                    //Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
                  });
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: pageIndex == 1 ? FontWeight.bold
                          : FontWeight.w400,
                      decoration: pageIndex == 1 ? TextDecoration.underline
                          : TextDecoration.none
                  ),
                ),
              ),
              SizedBox(width: 20.0,),
            ],
          ),
          Expanded(
            child: PageView.builder(
              itemCount: pages.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, position) => pages[pageIndex]
            ),
          )
        ],
      ),
    );
  }
}
