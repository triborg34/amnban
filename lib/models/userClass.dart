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
    collectionId = json['collectionId'];
    collectionName = json['collectionName'];
    id = json['id'];
    username = json['username'];
    password = json['password'];
    accsesslvl = json['accsesslvl'];
    email = json['email'];
    nickname = json['nickname'];
    created = json['created'];
    updated = json['updated'];
    rememberme=json['rememberme'];
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