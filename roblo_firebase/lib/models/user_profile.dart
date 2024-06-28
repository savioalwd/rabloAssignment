class UserProfile {
  String? uid;
  String? name;
  String? pfpURL;
  String? mobileNo;

  UserProfile({
    required this.uid,
    required this.name,
    required this.pfpURL,
    required this.mobileNo,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    pfpURL = json['pfpURL'];
    mobileNo = json['mobileNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['pfpURL'] = pfpURL;
    data['uid'] = uid;
    data['mobileNo'] = mobileNo;
    return data;
  }
}
