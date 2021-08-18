class Room {
  String? imageUrl;
  String? name;

  Room({this.imageUrl, this.name});

  Room.fromJson(Map<String, dynamic> json) {
    imageUrl = json['imageUrl'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['imageUrl'] = imageUrl;
    data['name'] = name;
    return data;
  }
}
