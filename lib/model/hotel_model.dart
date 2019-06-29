class HotelModel {
  int id;
  String img;
  String address;
  String phone;
  String description;
  String email;
  String rate;
  String name;
  String createdAt;
  String updatedAt;
  String priceOff;

  HotelModel(
      {this.id,
      this.address,
      this.phone,
      this.img,
      this.priceOff,
      this.description,
      this.email,
      this.rate,
      this.name,
      this.createdAt,
      this.updatedAt});

  HotelModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    phone = json['phone'];
    description = json['description'];
    email = json['email'];
    rate = json['rate'];
    name = json['name'];
    img = json['img'];
    priceOff = json['priceOff'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['description'] = this.description;
    data['email'] = this.email;
    data['rate'] = this.rate;
    data['name'] = this.name;
    data['img'] = this.img;
    data['priceOff'] = this.priceOff;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
