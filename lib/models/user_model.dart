class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // Role: doctor, patient, admin
  final int? age; // Age of the user, optional
  final String?
      gender; // Gender of the user (e.g., Male, Female, etc.), optional
  final String? healthStatus; // Health status of the user, optional

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.age, // Optional parameter
    this.gender, // Optional parameter
    this.healthStatus, // Optional parameter
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'age': age, // Age can be null
      'gender': gender, // Gender can be null
      'healthStatus': healthStatus, // Health status can be null
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'patient',
      age: map['age'], // Age can be null
      gender: map['gender'], // Gender can be null
      healthStatus: map['healthStatus'], // Health status can be null
    );
  }
}
