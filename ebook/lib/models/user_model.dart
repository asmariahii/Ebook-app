class UserModel {
  String? name;
  String? email;
  String? password;
  String? profilePicture;  // ADD THIS
  List<String>? favorites;
  DateTime? createdAt;     // ADD THIS
  DateTime? updatedAt;     // ADD THIS

  UserModel({
    this.name, 
    this.email, 
    this.password, 
    this.profilePicture,
    this.favorites,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json["name"],
        email: json["email"],
        password: json["password"],
        profilePicture: json["profilePicture"],  // ADD THIS
        favorites: json["favorites"] != null
            ? List<String>.from(json["favorites"].map((x) => x.toString()))
            : [],  // UPDATED THIS
        createdAt: json["createdAt"] != null 
            ? DateTime.parse(json["createdAt"]) 
            : null,  // ADD THIS
        updatedAt: json["updatedAt"] != null 
            ? DateTime.parse(json["updatedAt"]) 
            : null,  // ADD THIS
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "password": password,
        "favorites": favorites,
      };
}