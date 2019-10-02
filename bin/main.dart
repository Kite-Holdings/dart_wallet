import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/third_party_operations/airtel_kenya/b_c.dart';

Future main() async {
  // final app = Application<EPayGatewayChannel>()
  //     ..options.configurationFilePath = "config.yaml"
  //     ..options.port = 8888;

  // final count = Platform.numberOfProcessors ~/ 2;
  // await app.start(numberOfInstances: count > 0 ? count : 1);

  // print("Application started on port: ${app.options.port}.");
  // print("Use Ctrl-C (SIGINT) to stop running the application.");
  bTocTransaction();
}