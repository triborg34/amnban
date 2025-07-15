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
      this.ip});

  setting_class.fromJson(Map<String, dynamic> json) {
    id=json['id'];
    plateConf = json['plateConf'];
    charConf = json['charConf'];
    port = json['port'];
    isRfid = json['isRfid'];
    rl1 = json['rl1'];
    rl2 = json['rl2'];
    rfidip = json['rfidip'];
    rfidport = json['rfidport'];
    alarm = json['alarm'];
    quality = json['quality'];
    ip = json['ip'];
    rfconnect=json['rfconnect'];
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
    return data;
  }
}