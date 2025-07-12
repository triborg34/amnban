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
      this.created,
      this.updated});

  databaseClass.fromJson(Map<String, dynamic> json) {
    collectionId = json['collectionId'];
    collectionName = json['collectionName'];
    id = json['id'];
    plateNum = json['plateNum'];
    eDate = json['eDate'];
    eTime = json['eTime'];
    status = json['status'];
    isarvand = json['isarvand'];
    rtpath = json['rtpath'];
    charPercent = json['charPercent'];
    platePercent = json['platePercent'];
    imgpath = json['imgpath'];
    scrnPath = json['scrnPath'];
    created = json['created'];
    updated = json['updated'];
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
    return data;
  }
}