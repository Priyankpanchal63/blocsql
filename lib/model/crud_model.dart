class User {
  int? id;
  String? name;
  int? age;
  String? email;

  User({this.id, required this.age, required this.email, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        age: map['age'], email: map['email'], name: map['name'], id: map['id']);
  }
}
