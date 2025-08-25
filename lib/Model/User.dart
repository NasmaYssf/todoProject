class User {
  int? localId;
  int accountId;
  String email;
  String password;
  String? profilePhotoPath;
  bool synced;


  User({
    required this.accountId,
    required this.email,
    required this.password,
    this.localId,
    this.profilePhotoPath,
    this.synced = false,
  });

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      localId: json['id'],
      accountId: json['server_account_id'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      profilePhotoPath: json['profile_photo_path'],
      synced: json['synced'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': localId,
      'server_account_id': accountId,
      'email': email,
      'password': password,
      'profile_photo_path': profilePhotoPath,
      'synced': synced ? 1 : 0,
    };
  }

  User copyWith({
    int? accountId,
    String? email,
    String? password,
    String? profilePhotoPath,
  }) {
    return User(
      accountId: accountId ?? this.accountId,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
    );
  }
}
