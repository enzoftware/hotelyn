
class ProductModel {
  int id;
  String name;
  String description;
  String price;
  String imgUrl;
  int stock;

  ProductModel(
      {this.id,
      this.name,
      this.description,
      this.price,
      this.imgUrl,
      this.stock});

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    imgUrl = json['imgUrl'];
    stock = json['stock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['price'] = this.price;
    data['imgUrl'] = this.imgUrl;
    data['stock'] = this.stock;
    return data;
  }

  
}