import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
void airtelCTobTransaction() async {
  String payload = 
  '''
  <COMMAND>
  <TYPE>C2B</TYPE>
  <CUSTOMERMSISDN></CUSTOMERMSISDN>
  <MERCHANTMSISDN></MERCHANTMSISDN>
  <AMOUNT></AMOUNT>
  <PIN></PIN>
  <REFERENCE></REFERENCE>
  <USERNAME></USERNAME>
  <PASSWORD></PASSWORD>
  <REFERENCE1></REFERENCE1>
  </COMMAND>
  ''';

  final Map<String, String> headers = {
      'content-type': 'text/xml',
  };

  String url = "https://41.223.58.182:9193/MerchantPaymentService.asmx";
  bool trustSelfSigned = true;
  HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => trustSelfSigned);
  IOClient ioClient = new IOClient(httpClient);
  

  final http.Response res = await ioClient.post(url, headers: headers, body: payload);

  print(res.body);
}