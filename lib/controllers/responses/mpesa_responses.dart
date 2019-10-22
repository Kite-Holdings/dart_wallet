import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/mpesa%20models/mpesa_responses_model.dart';


class MpesaStkCallbackController extends ResourceController{
  @Operation.post()
  Future<Response> defaultStkCallback()async{
    final Map<String, dynamic> _body = await request.body.decode();
    _body['flag'] = "unprocessed";
    _body['type'] = "stkPush";

    MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel(body: _body);
    _mpesaResponsesModel.save();

    return Response.ok({"message": "done"});
  }

  @Operation.post('accRef')
  Future<Response> stkCallback(@Bind.path("accRef") String accRef)async{
    Map<String, dynamic> _body = await request.body.decode();
    _body['flag'] = "unprocessed";
    _body['type'] = "stkPush";
    _body['accRef'] = accRef;

    // ResultCode
    if(_body['Body']['stkCallback']['ResultCode'] == 0){
      Map<String, dynamic> _head = {};
      // MerchantRequestID
      _head['MerchantRequestID'] = _body['Body']['stkCallback']['MerchantRequestID'];
      // CheckoutRequestID
      _head['CheckoutRequestID'] = _body['Body']['stkCallback']['CheckoutRequestID'];

      final _details = _body['Body']['stkCallback']['CallbackMetadata']['Item'];
      Map<String, dynamic> _item = {};
      for(int i = 0; i < int.parse(_details.length.toString()); i++){
        _item[_details[i]['Name'].toString()] = _details[i]['Value'];
      }

      _body['MpesaReceiptNumber'] = _item['MpesaReceiptNumber'];

      _body['Body'] = {
        "head": _head,
        "data": _item
      };
      
      _body['flag'] = "complete";

      MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel(body: _body);
      _mpesaResponsesModel.save();
    }
    else{

      MpesaResponsesModel _mpesaResponsesModel = MpesaResponsesModel(body: _body);
      _mpesaResponsesModel.save();
    }

    // TODO: deposit to wallet

    return Response.ok({"message": "done"});
  }
}
