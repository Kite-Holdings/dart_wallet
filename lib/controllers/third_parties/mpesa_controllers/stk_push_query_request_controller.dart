import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/stkPushQueryRequest.dart';

class StkPushQueryRequestController extends ResourceController{
  @Operation.post()
  Future<Response> process()async{
    final _requestBody = await request.body.decode();
    final StkPushQueryRequest _stkPushQueryRequest = StkPushQueryRequest(checkoutRequestID: _requestBody['checkoutRequestID'].toString());
    final Map<String, dynamic> _res = await _stkPushQueryRequest.process();
    return Response.ok(_res);
  }
}