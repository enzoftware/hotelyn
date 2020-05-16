class HotelModel {
  String name;
  String address;
  String description;
  String imageUrl;
  int price;
  List<Room> rooms;
  List<Review> reviews;
  List<Amenitie> amenities;

  HotelModel({
    this.name,
    this.address,
    this.imageUrl,
    this.rooms,
    this.reviews,
    this.price,
    this.description,
    this.amenities,
  });

  HotelModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    description = json['description'];
    imageUrl = json['imageUrl'];
    address = json['address'];
    if (json['rooms'] != null) {
      rooms = List<Room>();
      json['rooms'].forEach((v) {
        rooms.add(Room.fromJson(v));
      });
    }
    if (json['reviews'] != null) {
      reviews = List<Review>();
      json['reviews'].forEach((v) {
        reviews.add(Review.fromJson(v));
      });
    }
    if (json['amenities'] != null) {
      amenities = List<Amenitie>();
      json['amenities'].forEach((v) {
        amenities.add(Amenitie.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    data['description'] = this.description;
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

class Room {
  String imageUrl;
  String name;

  Room({this.imageUrl, this.name});

  Room.fromJson(Map<String, dynamic> json) {
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

class Review {
  String message;
  String user;
  String userImage;
  double rate;

  Review({this.message, this.user, this.userImage, this.rate});

  Review.fromJson(Map<String, dynamic> json) {
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

class Amenitie {
  String name;
  String imageUrl;

  Amenitie({this.name, this.imageUrl});

  Amenitie.fromJson(Map<String, dynamic> json) {
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
