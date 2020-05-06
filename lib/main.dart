import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'ConnectionUtils.dart';
import 'DateUtils.dart';
import 'DockMappingScreen.dart';
import 'UrlConfig.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyApp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ProgressDialog pr;


  @override
  Widget build(BuildContext context) {

    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible:false,);
    pr.style(message: 'Authenticating...');

    pr.style(
      progress: 50.0,
      message: "Authenticating...",
      progressWidget: Container(
          padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );

    // get todays date and time and set to textview...
    String todaysDate=DateUtils.getTodaysDate();

    // check internet connection...
    ConnectionUtils.isNetworkPresent().then((connectionResult) {
     print(connectionResult);
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.blueAccent,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
        body:Center(
          child: Padding(
              padding: EdgeInsets.all(0),
              child: ListView(
                children: <Widget>[
                  Container(
                    height: 100.0,
                    color: Colors.blueAccent,
                    child: Text(todaysDate,textAlign:TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20.0,),),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'User Name',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        child: Text('Login'),
                        onPressed: () {
                          print(nameController.text);
                          print(passwordController.text);

                        // _makeGetRequest(nameController.text, passwordController.text);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DockMappingScreen()));

                        },
                      )),
                  Container(
                      child: Row(
                        children: <Widget>[
                          Text('Need Help ?'),
                          FlatButton(
                            textColor: Colors.blue,
                            child: Text(
                              'Contact IT Support',
                              style: TextStyle(fontSize: 15),
                            ),
                            onPressed: () {
                              //signup screen
                            },
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ))
                ],
              )),
        ),
        );
  }

  void _makeGetRequest(String userName, String password) async {
    if (userName.isEmpty) {
      Toast.show("Please enter username.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (password.isEmpty) {
      Toast.show("Please enter password.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {

      pr.show();
      String url = UrlConfig.BASE_URL +
          "GetLogin?LoginName=" +
          userName +
          "&Password=" +
          password;
      print("VALUE " + url);

      http.Response response =
          await http.get(url, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {

        String responseString = response.body.toString();
        if (responseString.length == 0 ||
            responseString == null ||
            responseString.isEmpty) {
          pr.hide();
          Toast.show("Please enter valid credentials", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else {
          pr.hide();
          String updatedResponse = responseString.replaceAll("\\", "");
          updatedResponse =
              updatedResponse.substring(1, updatedResponse.length);
          updatedResponse =
              updatedResponse.substring(0, updatedResponse.length - 1);

          List<dynamic> list = json.decode(updatedResponse);
          if (list.length > 0) {
            for (int i = 0; i < list.length; i++) {
              var value = list[i]['val'];
              if (value > 0) {

                  // save userid into shared preferences...
                  SharedPreferences preferences = await SharedPreferences.getInstance();
                  preferences.setString("UserId", value.toString());

                // redirect t next screen...
                Navigator.push(context, MaterialPageRoute(builder: (context) => DockMappingScreen()));

              } else {
                Toast.show("Please enter valid credentials", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                pr.hide();
               // Navigator.push(context, MaterialPageRoute(builder: (context) => DockMappingScreen()));
              }
            }
          } else {
            Toast.show("Please enter valid credentials", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          }
        }
      } else {
        Toast.show("Please enter valid credentials", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        throw Exception('Failed to load post');
      }
    }
  }
}
