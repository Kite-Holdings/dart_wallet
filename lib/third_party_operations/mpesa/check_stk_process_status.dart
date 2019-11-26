import 'package:e_pay_gateway/controllers/responses/mpesa_responses.dart';
import 'package:e_pay_gateway/models.dart/mpesa%20models/stk_process_model.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/stkPushQueryRequest.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';

Future<void> checkStkProcessStatus() async {
  const int _duration = 180000;

  final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'stkPushProcesses');
  final Map<String, dynamic> _map = await _databaseBridge.findBy(where.eq('processState', 'pending'));
  final _body = _map['body'];


  for(int i = 0; i < int.parse(_body.length.toString()); i++){
    final DateTime _processDatetime = DateTime.parse(_body[i]['timeInitiated'].toString()).toLocal();
    final DateTime _now = DateTime.now();
    final int _nowInt = _now.millisecondsSinceEpoch;
    final int _pastInt = _processDatetime.millisecondsSinceEpoch;
    final int _diff = _nowInt - _pastInt;
    
    // if duration is greter than 3 minutes query status
    if(_diff > _duration){

      final checkoutRequestID = _body[i]['checkoutRequestID'].toString();
      final String _id = _body[i]['_id'].toString().split('"')[1];
      if(checkoutRequestID != 'null'){
        final StkPushQueryRequest _stkPushQueryRequest = StkPushQueryRequest(checkoutRequestID: checkoutRequestID);

        final Map<String, dynamic> _querRes = await _stkPushQueryRequest.process();
        if(_querRes['status'] != 101){

          if(_querRes['status'] == 0){
            if(_querRes['resultCode'] == '0'){

              // Send callback
              try{
                processMpesaResponse(success: true, body: _querRes, recieptNo: _body[i]['_id'].toJson().toString(), requestId: _body[i]['requestId'].toString());

                // update state to complete
                final StkProcessModel _stkProcessModel = StkProcessModel(checkoutRequestID: checkoutRequestID, processState: ProcessState.complete);
                _stkProcessModel.updateProcessStateByCheckoutRequestID();
              } catch (e){
                print("Error!!!!!!!!!");
                print(e);
              }
            } else{
              
              // Send callback
              try{
                processMpesaResponse(success: false, body: _querRes, recieptNo: _body[i]['_id'].toJson().toString(), requestId: _body[i]['requestId'].toString());

                // update state to failed
                final StkProcessModel _stkProcessModel = StkProcessModel(checkoutRequestID: checkoutRequestID, processState: ProcessState.failed);
                _stkProcessModel.updateProcessStateByCheckoutRequestID();
              } catch (e){
                print("Error!!!!!!!!!");
                print(e);
              }
            }
          }
        }
      } else{
        // update state to terminated
        final StkProcessModel _stkProcessModel = StkProcessModel(processId: _id.toString(), processState: ProcessState.terminated);
        _stkProcessModel.updateProcessStateById();
      }
    }

  }
}