// Purpose: Represents a User entity from the DummyJSON API
// Responsibilities: Store user data and provide JSON serialization
// Why this class exists: To type-safe represent user data instead of using dynamic

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String accessToken;
  final String refreshToken;
  final int? age;
  final String contactNo;
  final String provider;
  final String uid;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.accessToken,
    required this.refreshToken,
    this.age,
    this.contactNo = '',
    this.provider = 'dummyJson',
    this.uid = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _asInt(json['id']) ?? 0,
      username: '${json['username'] ?? ''}',
      email: '${json['email'] ?? ''}',
      firstName: '${json['firstName'] ?? ''}',
      lastName: '${json['lastName'] ?? ''}',
      gender: '${json['gender'] ?? ''}',
      image: '${json['image'] ?? ''}',
      accessToken: '${json['accessToken'] ?? json['token'] ?? ''}',
      refreshToken: '${json['refreshToken'] ?? ''}',
      age: _asInt(json['age']),
      contactNo: '${json['contactNo'] ?? json['phone'] ?? ''}',
      provider: '${json['provider'] ?? 'dummyJson'}',
      uid: '${json['uid'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'age': age,
      'contactNo': contactNo,
      'provider': provider,
      'uid': uid,
    };
  }

  String get fullName => '$firstName $lastName'.trim();

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value');
  }
}
