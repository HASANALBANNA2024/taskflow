class UserModel {
  final String? id;
  final String email;
  final String firstName;
  final String lastName;
  final String mobile;

  UserModel({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.mobile,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    final res = (f + l).toUpperCase();
    return res.isEmpty ? '?' : res;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString(),
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson({String? password}) {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'mobile': mobile,
      if (password != null) 'password': password,
    };
  }
}
