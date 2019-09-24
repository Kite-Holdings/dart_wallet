import 'package:mongo_dart/mongo_dart.dart';

Future<int> companyCounter (String documentLabel)async {
  final Db db = new Db("mongodb://localhost:27017/wallet");
  await db.open();
  DbCollection counterCollection = db.collection('counters');

  var doc = await counterCollection.findOne({'label': documentLabel});
  if(doc == null){
    await counterCollection.insert({
      'label': documentLabel,
      'value': 0,
    });
  }


  Map<String, dynamic> newc =await counterCollection.findAndModify(
    query: {"label": documentLabel},
    update: {"\$inc":{'value':1}},
    returnNew: true,

  );
  await db.close();
  var value = newc['value'].toString();
  return int.parse(value);
}