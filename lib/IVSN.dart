import 'dart:convert';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/DockMappingScreen.dart';
import 'package:flutterapp/FourthScreen.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'DateUtils.dart';
import 'UrlConfig.dart';

class IVSN extends StatelessWidget {
  final String docknumber;

  IVSN(this.docknumber);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(docknumber),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String docknumber;

  MyHomePage(this.docknumber);

  @override
  _MyHomePageState createState() => _MyHomePageState(docknumber);
}

class _MyHomePageState extends State<MyHomePage> {
  var ivsBarcodeValue = new TextEditingController();
  ProgressDialog pr;
  final String docknumber;

  var _isButtonDisabled=true;

  _MyHomePageState(this.docknumber);

  // get todays date and time and set to textview...
  String todaysDate = DateUtils.getTodaysDate();

  Future scanCode() async {
    try {
      String barcode = await BarcodeScanner.scan();
      // setState(() => this.barcode = barcode);
      setState(() {
        ivsBarcodeValue.text = barcode;
      });
      print("Barcode is " + barcode);
    } catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Toast.show("Camera permission denied.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        Toast.show("Error occoured,please try again later.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: true,
    );
    pr.style(
      progress: 50.0,
      message: "Getting count...",
      progressWidget: Container(
          padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("IVS DETAILS"),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
                      child: Text(
                        "Enter IVS number",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0,color: Colors.black),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                    child: TextFormField(
                      controller: ivsBarcodeValue,
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) {
                       // callWebServiceForGetCount(value, context);
                        setState((){
                          _isButtonDisabled = false;
                        });
                      },
                      decoration: new InputDecoration(
                        hintText: '0-123-456-789',
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(0.0),
                          ),
                          borderSide: new BorderSide(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      children: <Widget>[
                        RaisedButton(
                          child: Text(
                            'Scan IVS number',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          textColor: Colors.black,
                          onPressed: scanCode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 50.0,
                    child: RaisedButton(
                      child: Text(
                        'BACK',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      ),
                      color: Colors.white,
                      onPressed: () {
                        Route route = MaterialPageRoute(builder: (context) => DockMappingScreen());
                        Navigator.pushReplacement(context, route);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 50.0,
                    child: RaisedButton(
                      child: Text(
                        'Continue',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      color: Colors.blueAccent,
                      onPressed: _isButtonDisabled ? null : () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FourthScreen(docknumber)));},

                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void callWebServiceForGetCount(String value, BuildContext context) async {

    _isButtonDisabled=true;
    if (value.isEmpty) {
      Toast.show("Please enter IVS number.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      pr.show();
      // get the userid from shared preferences...
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString("UserId");

      String subUrl = "GetIVSNData?IVSNNO=" +
          value +
          "&DockNo=" +
          docknumber +
          "&UserId=" +
          userId;
      String url = UrlConfig.BASE_URL + subUrl;
      http.Response response =
          await http.get(url, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        String responseString = response.body.toString();
        if (responseString.length == 0 ||
            responseString == null ||
            responseString.isEmpty ||
            responseString == "null") {
          pr.hide();
          Toast.show("Error occoured, please try again later.", context,
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
              int count = list[i]['cnt'];
              if (count <= 0) {
                setState((){
                  _isButtonDisabled = false;
                });
                Toast.show("Box not loaded.", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              } else {
                setState((){
                  _isButtonDisabled = false;
                });
                Toast.show(count.toString() + " loaded successfully.", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              }
            }
          } else {
            Toast.show("Error occoured, please try again later.", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          }
        }
      } else {
        pr.hide();
        Toast.show("Error occoured, please try again later.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        throw Exception('Failed to load post');
      }
    }
  }
}
