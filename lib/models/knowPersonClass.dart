import 'package:amnban/utils/safe.dart';

class knowPersonBox {
  String? collectionId;
  String? collectionName;
  String? id;
  String? plateImagePath;
  String? name;
  String? carName;
  String? eDate;
  String? eTime;
  bool? status;
  String? screenImg;
  String? role;
  String? socialNumber;
  String? isarvand;
  String? rtpath;
  String? plateNumber;
  String? created;
  String? updated;
  String? firstTwoDigit;
  String? threeDigit;
  String? lastTwoDigit;
  String? engishAlphabet;
  String? persianAlhpabet;

  knowPersonBox(
      {this.collectionId,
      this.collectionName,
      this.id,
      this.plateImagePath,
      this.name,
      this.carName,
      this.eDate,
      this.eTime,
      this.status,
      this.screenImg,
      this.role,
      this.socialNumber,
      this.isarvand,
      this.rtpath,
      this.plateNumber,
      this.created,
      this.firstTwoDigit,
      this.lastTwoDigit,
      this.threeDigit,
      this.engishAlphabet,
      this.persianAlhpabet,
      this.updated});

  knowPersonBox.fromJson(Map<String, dynamic> json) {
    collectionId = asString(json['collectionId']);
    collectionName = asString(json['collectionName']);
    id = asString(json['id']);
    plateImagePath = asString(json['plateImagePath']);
    name = asString(json['name']);
    carName = asString(json['carName']);
    eDate = asString(json['eDate']);
    eTime = asString(json['eTime']);
    status = asBool(json['status']);
    screenImg = asString(json['screenImg']);
    role = asString(json['role']);
    socialNumber = asString(json['socialNumber']);
    isarvand = asString(json['isarvand']);
    rtpath = asString(json['rtpath']);
    plateNumber = asString(json['plateNumber']);
    created = asString(json['created']);
    updated = asString(json['updated']);
    firstTwoDigit = asString(json['firstTwoDigit']);
    threeDigit = asString(json['threeDigit']);
    lastTwoDigit = asString(json['lastTwoDigit']);
    // NOTE: the collection historically used misspelled keys. Read the
    // misspelled key first (current contract) but fall back to the correct
    // spelling so either one works. Writes keep the old key to avoid
    // breaking the backend.
    persianAlhpabet = asString(json['persinalAlphabet']) ??
        asString(json['persianAlphabet']) ??
        asString(json['persianAlhpabet']);
    engishAlphabet = asString(json['englishAlphabet']) ??
        asString(json['engishAlphabet']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['collectionId'] = this.collectionId;
    data['collectionName'] = this.collectionName;
    data['id'] = this.id;
    data['plateImagePath'] = this.plateImagePath;
    data['name'] = this.name;
    data['carName'] = this.carName;
    data['eDate'] = this.eDate;
    data['eTime'] = this.eTime;
    data['status'] = this.status;
    data['screenImg'] = this.screenImg;
    data['role'] = this.role;
    data['socialNumber'] = this.socialNumber;
    data['isarvand'] = this.isarvand;
    data['rtpath'] = this.rtpath;
    data['plateNumber'] = this.plateNumber;
    data['created'] = this.created;
    data['updated'] = this.updated;
    data['firstTwoDigit'] = this.firstTwoDigit;
    data['threeDigit'] = this.threeDigit;
    data['lastTwoDigit'] = this.lastTwoDigit;
    data['persinalAlphabet'] = this.persianAlhpabet;
    data['englishAlphabet'] = this.engishAlphabet;

    return data;
  }
}
