import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'UrlConfig.dart';

// ignore: must_be_immutable
class FourthScreen extends StatefulWidget {
  final String docknumber;

  FourthScreen(this.docknumber);

  @override
  _MyHomePageState createState() => _MyHomePageState(docknumber);
}

class _MyHomePageState extends State<FourthScreen> {
  ProgressDialog pr;
  String clickedValue = "";
  var vendorController = new TextEditingController();
  var fscController = new TextEditingController();

  final String docknumber;

  _MyHomePageState(this.docknumber);

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: true,
    );
    pr.style(
      progress: 50.0,
      message: "Updating barcode...",
      progressWidget: Container(
          padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("IVS DETAILS"),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Dock " + docknumber,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                child: Text(
                  "Pair Barcode - Std ",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20.0, color: Colors.black),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Vendor Barcode",
                            textAlign: TextAlign.left,
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.black),
                          ),
                          Text(
                            "Scan Vendor Barcode",
                            textAlign: TextAlign.left,
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.grey),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
                            child: TextField(
                              readOnly: true,
                              controller: vendorController,
                              onTap: () {
                                scanCode(context, "vendor");
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Vendor Barcode',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "FSC Barcode",
                            textAlign: TextAlign.left,
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.black),
                          ),
                          Text(
                            "Scan FSC Barcode",
                            textAlign: TextAlign.left,
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.grey),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
                            child: TextField(
                              readOnly: true,
                              controller: fscController,
                              onTap: () {
                                scanCode(context, "fsc");
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'FSC Barcode',
                              ),
                            ),
                          ),
                          RaisedButton(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            color: Colors.blueAccent,
                            onPressed: () {
                              webServiceCallToUpadateBarcode(
                                  vendorController.text,
                                  fscController.text,
                                  docknumber,
                                  context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future scanCode(BuildContext context, String clickedValue) async {
    this.clickedValue = clickedValue;
    try {
      String barcode = await BarcodeScanner.scan();
      if (this.clickedValue == 'vendor') {
        vendorController.text = barcode;
      } else if (this.clickedValue == 'fsc') {
        //check vendor barcode is empty...
        if (vendorController.text.length == 0) {
          Toast.show("Please scan vendor barcode first.", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else if (barcode.substring(0, 1) != "f" || barcode.substring(0, 1) != "F") {
          Toast.show("FSC barcode should starts with F.", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }else if(barcode.length > 10)
          {
            Toast.show("FSC barcode should not greater than 10 digits.", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          }else if(barcode.length < 10)
            {
              Toast.show("FSC barcode should not less than 10 digits.", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            }else if(barcode.length==10)
              {
                fscController.text = barcode;
              }
         }
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

  void webServiceCallToUpadateBarcode(String vendorBarcode, String fscBarcode,
      String docknumber, BuildContext context) async {

    // TODO change this condition to !=0  .....
    if (vendorBarcode.length == 0 && fscBarcode.length == 0) {
      //TODO remove these values and pass from function value...
      String vendorBarcodee = "100021545552";
      String fscBarcode = "F000012221";
      String userId = "3";

      pr.show();
      // get the userid from shared preferences...
      SharedPreferences preferences = await SharedPreferences.getInstance();
      // String userId = preferences.getString("UserId");

      String subUrl = "ScanBarcode?VB=" +
          vendorBarcodee +
          "&FB=" +
          fscBarcode +
          "&D=" +
          userId;
      String url = UrlConfig.BASE_URL + subUrl;
      print(url);
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
          if (list.length <= 0) {
            Toast.show("Error occoured, please try again later.", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          } else {
            for (int i = 0; i < list.length; i++) {
              int errorId = list[i]['ErrorID'];
              // handle error id...
              if (errorId == 2) {
                Toast.show("Start unloading first.", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                vendorController.text = "";
                fscController.text = "";

                //TODO move this code to error ID =1...
                showCustomAlert(context,vendorBarcodee,fscBarcode,userId);

              } else if (errorId == 10) {
                Toast.show("Vendor barcode not exist.", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                vendorController.text = "";
                fscController.text = "";
              } else if (errorId == 20) {
                Toast.show("Excess box.", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                vendorController.text = "";
                fscController.text = "";
              } else if (errorId == 30) {
                Toast.show(
                    "Box id already exist for this vendor barcode.", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                vendorController.text = "";
                fscController.text = "";
              } else if (errorId == 5) {
                Toast.show("SKU already Qc reject.", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                vendorController.text = "";
                fscController.text = "";
              } else if (errorId == 1) {}
            }
          }
        }
      } else {
        pr.hide();
        Toast.show("Error occoured, please try again later.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        throw Exception('Failed to load post');
      }
    } else {
      Toast.show("Please scan both barcodes before proceeding.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void showCustomAlert(BuildContext context,String vendorBarcode,String fscBarcode,String userId) {

    String dropdownValue;
    // TODO use list from webservices...
    List<String> spinnerItems = [
      '45461221511',
      '45461221512',
      '45461221513',
      '45461221514'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: EdgeInsets.all(20.0),
                  padding: EdgeInsets.all(15.0),
                  height: 150.0,
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0))),
                  child: Column(
                    children: <Widget>[
                      // set dropdown...
                      DropdownButton<String>(
                        hint: Text("Select POKEY value"),
                        value: dropdownValue,
                        onChanged: (String Value) {
                          setState(() {
                            dropdownValue = Value;
                          });
                        },
                        items: spinnerItems.map((String user) {
                          return DropdownMenuItem<String>(
                            value: user,
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  user,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ButtonTheme(
                                  height: 35.0,
                                  minWidth: 110.0,
                                  child: RaisedButton(
                                    color: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    splashColor: Colors.white.withAlpha(40),
                                    child: Text(
                                      'UPDATE',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.0),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      callWebserviceToUpdatePOKEy(dropdownValue,vendorBarcode,fscBarcode,userId);
                                    },
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void callWebserviceToUpdatePOKEy(String dropdownValue,String vendorBarcode,String fscBarcode,String userId) async{
    if (dropdownValue == null || dropdownValue.length == 0) {
    } else {

      pr.show();
      pr.style(message: 'Updating POKEY Value...');
      String subUrl = "LoadDetails_UpdatePOKEY?VB="+vendorBarcode+"&FB="+fscBarcode+"&Po="+dropdownValue+"&D="+userId;
      String url = UrlConfig.BASE_URL + subUrl;
      print(url);
      http.Response response = await http.get(url, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        String responseString = response.body.toString();
        if (responseString.length == 0 || responseString == null || responseString.isEmpty || responseString == "null") {
          pr.hide();
          Toast.show("Error occoured, please try again later.", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else {
          pr.hide();
          String updatedResponse = responseString.replaceAll("\\", "");
          updatedResponse = updatedResponse.substring(1, updatedResponse.length);
          updatedResponse = updatedResponse.substring(0, updatedResponse.length - 1);

          List<dynamic> list = json.decode(updatedResponse);
          if (list.length <= 0) {
            Toast.show("Error occoured, please try again later.", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          } else {
            for (int i = 0; i < list.length; i++) {
              // TODO what to do with status....
              int Status = list[i]['Status'];
              print("Status is "+Status.toString());
            }
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
