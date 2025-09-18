class UserModel {
  String? name;
  String? email;
  String? password;
  List<String>? favorites; // <-- add this

  UserModel({this.name, this.email, this.password, this.favorites});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json["name"],
        email: json["email"],
        password: json["password"],
        favorites: json["favorites"] != null
            ? List<String>.from(json["favorites"])
            : [],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "password": password,
        "favorites": favorites,
      };
}
