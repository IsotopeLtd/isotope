class User {
  final String id;
  final String name;
  final String email;

  User({this.id, this.name, this.email});

  User.fromData(Map<String, dynamic> data)
    : id = data['id'],
      email = data['email'],
      name = data['name'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}
