import 'package:connectivity/connectivity.dart';
class ConnectionUtils
{
    static Future<bool> isNetworkPresent() async
    {
      bool isNetworkPresent=false;
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        isNetworkPresent=true;
      } else {
        isNetworkPresent=false;
      }
      return isNetworkPresent;
    }
}