import 'package:flutter/material.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'IVSN.dart';
import 'ScanBarcodeScreen.dart';
import 'UrlConfig.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'dart:convert';

// ignore: must_be_immutable
class DockMappingScreen extends StatelessWidget {
  var dockNumberList = new List<int>();
  ProgressDialog pr;

  @override
  Widget build(BuildContext context) {

    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible:true,);

    pr.style(
      progress: 50.0,
      message: "Getting IVS number...",
      progressWidget: Container(
          padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );

    // form the dynamic dock data for selection...
    for (int i = 0; i < 10; i++) {
      dockNumberList.add(i + 1);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Dock Details'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: dockNumberList
            .map((dockNumber) => Card(
          child: InkWell(
            onTap: ()  {

             /*// showDialog(context: context,builder: (context) => _onTapImage(context,dockNumber));
              showDialog(context: context, barrierDismissible: false,
                builder: (c) => _onTapImage(context,dockNumber,c));*/

              Navigator.push(context, MaterialPageRoute(builder: (context) => IVSN(dockNumber.toString())));

             /* Route route = MaterialPageRoute(builder: (context) => IVSN(dockNumber.toString()));
              Navigator.pushReplacement(context, route);*/

            },
            child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(dockNumber.toString()),
                )),
          ),
        ))
            .toList(),
      ),
    );
  }

  void webServiceCallToGetIVSNumber(String docknumber, BuildContext context, BuildContext c) async {

    print("Hello there");
    Navigator.pop(c);
   // Navigator.push(context, MaterialPageRoute(builder: (context) => IVSN()));

    pr.show();
    String subUrl="CheckDockStatus?DockNo="+docknumber;
    String url = UrlConfig.BASE_URL + subUrl;
    print("VALUE " + url);
    http.Response response = await http.get(url, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      String responseString = response.body.toString();
      if (responseString.length == 0 || responseString == null || responseString.isEmpty || responseString=="null") {
        pr.hide();
        Toast.show("Error occoured, please try again later.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        pr.hide();
        String updatedResponse = responseString.replaceAll("\\", "");
        updatedResponse = updatedResponse.substring(1, updatedResponse.length);
        updatedResponse = updatedResponse.substring(0, updatedResponse.length - 1);

        List<dynamic> list = json.decode(updatedResponse);
        if (list.length > 0) {
          for (int i = 0; i < list.length; i++) {
            String masterId = list[i]['MasterID'];
            print("hide progressbar"+masterId);
            if(masterId.isEmpty || masterId=="null" || masterId==null)
            {
             // Navigator.push(context, MaterialPageRoute(builder: (context) => IVSN()));
              Route route = MaterialPageRoute(builder: (context) => IVSN(docknumber.toString()));
              Navigator.pushReplacement(context, route);

            }else
              {
               // Navigator.push(context, MaterialPageRoute(builder: (context) => ScanBarcodeScreen()));
              }
            break;
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

  _onTapImage(BuildContext context, int dockNumber, BuildContext c) {

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(15.0),
              height: 100.0,

          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0))
          ),

          child:Column(
            children: <Widget>[
              Text("Do you want to continue with dock number "+dockNumber.toString()+" .",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),

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
                            color: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            splashColor: Colors.white.withAlpha(40),
                            child: Text(
                              'OK',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0),
                            ),
                            onPressed:() {

                              webServiceCallToGetIVSNumber(dockNumber.toString(),context,c);
                              },
                          )),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ButtonTheme(
                          height: 35.0,
                          minWidth: 110.0,
                          child: RaisedButton(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            splashColor: Colors.white.withAlpha(40),
                            child: Text(
                              'CANCEL',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0),
                            ),
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
  }
}