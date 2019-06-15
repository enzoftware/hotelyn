class UserModel {
  int id;
  String username;
  String role;
  String email;
  int age;
  String firstName;
  String lastName;
  bool bookingEnabled;

  UserModel(
      {this.id,
      this.username,
      this.role,
      this.email,
      this.age,
      this.firstName,
      this.lastName,
      this.bookingEnabled});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    role = json['role'];
    email = json['email'];
    age = json['age'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    bookingEnabled = json['bookingEnabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['role'] = this.role;
    data['email'] = this.email;
    data['age'] = this.age;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['bookingEnabled'] = this.bookingEnabled;
    return data;
  }
}
