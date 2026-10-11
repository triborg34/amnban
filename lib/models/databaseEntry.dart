import 'package:amnban/utils/safe.dart';

class databaseClass {
  String? collectionId;
  String? collectionName;
  String? id;
  String? plateNum;
  String? eDate;
  String? eTime;
  String? status;
  String? isarvand;
  String? rtpath;
  int? charPercent;
  int? platePercent;
  String? imgpath;
  String? scrnPath;
  String? created;
  String? updated;
  String? provice;
  String? city;

  databaseClass(
      {this.collectionId,
      this.collectionName,
      this.id,
      this.plateNum,
      this.eDate,
      this.eTime,
      this.status,
      this.isarvand,
      this.rtpath,
      this.charPercent,
      this.platePercent,
      this.imgpath,
      this.scrnPath,
      this.city,this.provice,
      this.created,
      this.updated});

  databaseClass.fromJson(Map<String, dynamic> json) {
    collectionId = asString(json['collectionId']);
    collectionName = asString(json['collectionName']);
    id = asString(json['id']);
    plateNum = asString(json['plateNum']);
    eDate = asString(json['eDate']);
    eTime = asString(json['eTime']);
    status = asString(json['status']);
    isarvand = asString(json['isarvand']);
    rtpath = asString(json['rtpath']);
    charPercent = asInt(json['charPercent']);
    platePercent = asInt(json['platePercent']);
    imgpath = asString(json['imgpath']);
    scrnPath = asString(json['scrnPath']);
    created = asString(json['created']);
    updated = asString(json['updated']);
    city=asString(json['city']);
    provice=asString(json['provice']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['collectionId'] = this.collectionId;
    data['collectionName'] = this.collectionName;
    data['id'] = this.id;
    data['plateNum'] = this.plateNum;
    data['eDate'] = this.eDate;
    data['eTime'] = this.eTime;
    data['status'] = this.status;
    data['isarvand'] = this.isarvand;
    data['rtpath'] = this.rtpath;
    data['charPercent'] = this.charPercent;
    data['platePercent'] = this.platePercent;
    data['imgpath'] = this.imgpath;
    data['scrnPath'] = this.scrnPath;
    data['created'] = this.created;
    data['updated'] = this.updated;
    data['provice']=this.provice;
    data['city']=this.city;
    return data;
  }
}