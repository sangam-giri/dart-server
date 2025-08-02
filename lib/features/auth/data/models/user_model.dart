// class UserModel {
//   final String? id;
//   final String email;
//   final String passwordHash;
//   final DateTime createdAt;

//   UserModel({
//     this.id,
//     required this.email,
//     required this.passwordHash,
//     required this.createdAt,
//   });

//   // Convert to JSON for database
//   Map<String, dynamic> toJson() => {
//     if (id != null) '_id': id,
//     'email': email,
//     'passwordHash': passwordHash,
//     'createdAt': createdAt.toIso8601String(),
//   };

//   // Parse from database JSON
//   factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
//     id: json['_id']?.toString(),
//     email: json['email'],
//     passwordHash: json['passwordHash'],
//     createdAt: DateTime.parse(json['createdAt']),
//   );

//   // Create a copy with updated fields
//   UserModel copyWith({
//     String? id,
//     String? email,
//     String? passwordHash,
//     DateTime? createdAt,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       email: email ?? this.email,
//       passwordHash: passwordHash ?? this.passwordHash,
//       createdAt: createdAt ?? this.createdAt,
//     );
//   }

//   // Convert to Domain Entity
//   UserEntity toEntity() {
//     return UserEntity(
//       id: id,
//       email: email,
//       passwordHash: passwordHash,
//       createdAt: createdAt,
//     );
//   }
// }
