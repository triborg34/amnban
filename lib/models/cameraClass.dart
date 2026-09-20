import 'package:amnban/utils/safe.dart';

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
    collectionId = asString(json['collectionId']);
    collectionName = asString(json['collectionName']);
    id = asString(json['id']);
    name = asString(json['name']);
    ip = asString(json['ip']);
    gate = asString(json['gate']);
    username = asString(json['username']);
    password = asString(json['password']);
    path = asString(json['path']);
    rtspUrl = asString(json['rtspUrl']);
    rtspName = asString(json['rtspName']);
    created = asString(json['created']);
    updated = asString(json['updated']);
    port=asString(json['port']);
    isRtsp=asBool(json['isRtsp']);
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