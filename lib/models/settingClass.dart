import 'package:amnban/utils/safe.dart';

class setting_class {
  String? id;
  double? plateConf;
  double? charConf;
  String? port;
  bool? isRfid;
  bool? rl1;
  bool? rl2;
  String? rfidip;
  int? rfidport;
  bool? alarm;
  int? quality;
  String? ip;
  bool? rfconnect;
  bool? notif;
  bool? isBadNetwork;
  setting_class(

      {
        this.id,
        this.plateConf,
      this.charConf,
      this.port,
      this.isRfid,
      this.rl1,
      this.rl2,
      this.rfidip,
      this.rfidport,
      this.alarm,
      this.quality,
      this.rfconnect,
      this.isBadNetwork ,
      this.ip,this.notif});

  setting_class.fromJson(Map<String, dynamic> json) {
    id=asString(json['id']);
    // Server sometimes sends int where the app expects double (and vice
    // versa) — coercing here prevents type-cast crashes.
    plateConf = asDouble(json['plateConf']);
    charConf = asDouble(json['charConf']);
    port = asString(json['port']);
    isRfid = asBool(json['isRfid']);
    rl1 = asBool(json['rl1']);
    rl2 = asBool(json['rl2']);
    rfidip = asString(json['rfidip']);
    rfidport = asInt(json['rfidport']);
    alarm = asBool(json['alarm']);
    quality = asInt(json['quality']);
    ip = asString(json['ip']);
    rfconnect=asBool(json['rfconnect']);
    notif=asBool(json['notif']);
    isBadNetwork= asBool(json['isBadNetwork']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['plateConf'] = this.plateConf;
    data['charConf'] = this.charConf;
    data['port'] = this.port;
    data['isRfid'] = this.isRfid;
    data['rl1'] = this.rl1;
    data['rl2'] = this.rl2;
    data['rfidip'] = this.rfidip;
    data['rfidport'] = this.rfidport;
    data['alarm'] = this.alarm;
    data['quality'] = this.quality;
    data['ip'] = this.ip;
    data["id"]=this.id;
    data['rfconnect']=this.rfconnect;
    data['notif']=this.notif;
    data['isBadNetwork']=this.isBadNetwork;
    return data;
  }
}