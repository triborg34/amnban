class CameraClass {
  String? collectionId;
  String? collectionName;
  String? id;
  String? name;
  String? ip;
  String? gate;
  String? username;
  String? password;
  String? path;
  String? rtspUrl;
  String? rtspName;
  String? created;
  String? updated;
  String? port;
  bool? isRtsp;

  CameraClass(
      {this.collectionId,
      this.collectionName,
      this.id,
      this.name,
      this.ip,
      this.gate,
      this.username,
      this.password,
      this.path,
      this.rtspUrl,
      this.rtspName,
      this.created,
      this.port,
      this.isRtsp,
      this.updated});

  CameraClass.fromJson(Map<String, dynamic> json) {
    collectionId = json['collectionId'];
    collectionName = json['collectionName'];
    id = json['id'];
    name = json['name'];
    ip = json['ip'];
    gate = json['gate'];
    username = json['username'];
    password = json['password'];
    path = json['path'];
    rtspUrl = json['rtspUrl'];
    rtspName = json['rtspName'];
    created = json['created'];
    updated = json['updated'];
    port=json['port'];
    isRtsp=json['isRtsp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['collectionId'] = this.collectionId;
    data['collectionName'] = this.collectionName;
    data['id'] = this.id;
    data['name'] = this.name;
    data['ip'] = this.ip;
    data['gate'] = this.gate;
    data['username'] = this.username;
    data['password'] = this.password;
    data['path'] = this.path;
    data['rtspUrl'] = this.rtspUrl;
    data['rtspName'] = this.rtspName;
    data['created'] = this.created;
    data['updated'] = this.updated;
    data['port']=this.port;
    data['isRtsp']=this.isRtsp;
    return data;
  }
}