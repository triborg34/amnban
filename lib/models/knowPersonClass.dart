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
    collectionId = json['collectionId'];
    collectionName = json['collectionName'];
    id = json['id'];
    plateImagePath = json['plateImagePath'];
    name = json['name'];
    carName = json['carName'];
    eDate = json['eDate'];
    eTime = json['eTime'];
    status = json['status'];
    screenImg = json['screenImg'];
    role = json['role'];
    socialNumber = json['socialNumber'];
    isarvand = json['isarvand'];
    rtpath = json['rtpath'];
    plateNumber = json['plateNumber'];
    created = json['created'];
    updated = json['updated'];
    firstTwoDigit = json['firstTwoDigit'];
    threeDigit = json['threeDigit'];
    lastTwoDigit = json['lastTwoDigit'];
    persianAlhpabet = json['persinalAlphabet'];
    engishAlphabet = json['englishAlphabet'];
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
    data['persianAlhpabet'] = this.persianAlhpabet;
    data['englishAlphabet'] = this.engishAlphabet;

    return data;
  }
}
