class Review {
  String message;
  String user;
  String userImage;
  int rate;

  Review({
    this.message,
    this.user,
    this.userImage,
    this.rate,
  });

  Review.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    user = json['user'];
    userImage = json['userImage'];
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['user'] = user;
    data['userImage'] = userImage;
    data['rate'] = rate;
    return data;
  }
}
