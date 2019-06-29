class HotelModel {
  int id;
  String address;
  String phone;
  String description;
  String email;
  String rate;
  String name;

  HotelModel(
      {this.id,
      this.address,
      this.phone,
      this.description,
      this.email,
      this.rate,
      this.name});

  HotelModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    phone = json['phone'];
    description = json['description'];
    email = json['email'];
    rate = json['rate'];
    name = json['name'];
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
    return data;
  }
}
