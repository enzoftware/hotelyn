class HotelModel {
  String name;
  String address;
  String imageUrl;
  int price;
  List<Rooms> rooms;
  List<Reviews> reviews;
  List<Amenities> amenities;

  HotelModel({
    this.name,
    this.address,
    this.imageUrl,
    this.rooms,
    this.reviews,
    this.price,
    this.amenities,
  });

  HotelModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    imageUrl = json['imageUrl'];
    address = json['address'];
    if (json['rooms'] != null) {
      rooms = List<Rooms>();
      json['rooms'].forEach((v) {
        rooms.add(Rooms.fromJson(v));
      });
    }
    if (json['reviews'] != null) {
      reviews = List<Reviews>();
      json['reviews'].forEach((v) {
        reviews.add(Reviews.fromJson(v));
      });
    }
    if (json['amenities'] != null) {
      amenities = List<Amenities>();
      json['amenities'].forEach((v) {
        amenities.add(Amenities.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    data['address'] = this.address;
    data['imageUrl'] = this.imageUrl;
    if (this.rooms != null) {
      data['rooms'] = this.rooms.map((v) => v.toJson()).toList();
    }
    if (this.reviews != null) {
      data['reviews'] = this.reviews.map((v) => v.toJson()).toList();
    }
    if (this.amenities != null) {
      data['amenities'] = this.amenities.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Rooms {
  String imageUrl;
  String name;

  Rooms({this.imageUrl, this.name});

  Rooms.fromJson(Map<String, dynamic> json) {
    imageUrl = json['imageUrl'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['imageUrl'] = this.imageUrl;
    data['name'] = this.name;
    return data;
  }
}

class Reviews {
  String message;
  String user;
  String userImage;
  int rate;

  Reviews({this.message, this.user, this.userImage, this.rate});

  Reviews.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    user = json['user'];
    userImage = json['userImage'];
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['message'] = this.message;
    data['user'] = this.user;
    data['userImage'] = this.userImage;
    data['rate'] = this.rate;
    return data;
  }
}

class Amenities {
  String name;
  String imageUrl;

  Amenities({this.name, this.imageUrl});

  Amenities.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}
