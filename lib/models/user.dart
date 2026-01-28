class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String contact;
  final String address;
  final String birthday;
  final String token;

  User.fromJson(Map<String, dynamic> json)
    : id = json["customer_id"] ?? '',
      email = json["email"] ?? '',
      firstName = json["first_name"] ?? '',
      lastName = json["last_name"] ?? '',
      gender = json["gender"] ?? '',
      contact = json["contact_number"] ?? '',
      address = json["address"] ?? '',
      birthday = json["birthday"] ?? '',
      token = json["token"] ?? '';
}
