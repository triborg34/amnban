import 'package:amnban/utils/safe.dart';

class userClass {
  String? collectionId;
  String? collectionName;
  String? id;
  String? username;
  String? password;
  String? accsesslvl;
  String? email;
  String? nickname;
  String? created;
  String? updated;
  bool? rememberme;

  userClass(
      {this.collectionId,
      this.collectionName,
      this.id,
      this.username,
      this.password,
      this.accsesslvl,
      this.email,
      this.nickname,
      this.created,
      this.rememberme,
      this.updated});

  userClass.fromJson(Map<String, dynamic> json) {
    collectionId = asString(json['collectionId']);
    collectionName = asString(json['collectionName']);
    id = asString(json['id']);
    username = asString(json['username']);
    password = asString(json['password']);
    accsesslvl = asString(json['accsesslvl']);
    email = asString(json['email']);
    nickname = asString(json['nickname']);
    created = asString(json['created']);
    updated = asString(json['updated']);
    rememberme=asBool(json['rememberme']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['collectionId'] = this.collectionId;
    data['collectionName'] = this.collectionName;
    data['id'] = this.id;
    data['username'] = this.username;
    data['password'] = this.password;
    data['accsesslvl'] = this.accsesslvl;
    data['email'] = this.email;
    data['nickname'] = this.nickname;
    data['created'] = this.created;
    data['updated'] = this.updated;
    data['rememberme']=this.rememberme;
    return data;
  }
}