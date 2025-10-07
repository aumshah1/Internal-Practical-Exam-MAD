import 'dart:convert';

class Member {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? address;
  final String? planId;
  final String startDate; // ISO8601
  final String? expiryDate; // ISO8601
  final String? nextDueDate; // ISO8601 - when next fee is due
  final bool active;
  final String createdAt;
  final String updatedAt;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.address,
    this.planId,
    this.nextDueDate,
    required this.startDate,
    this.expiryDate,
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Member copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
    String? planId,
    String? startDate,
    String? expiryDate,
    String? nextDueDate,
    bool? active,
    String? createdAt,
    String? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      planId: planId ?? this.planId,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'address': address,
        'planId': planId,
        'startDate': startDate,
        'expiryDate': expiryDate,
        'nextDueDate': nextDueDate,
        'active': active,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
    address: json['address'] as String?,
    planId: json['planId'] as String?,
        startDate: json['startDate'] as String,
        expiryDate: json['expiryDate'] as String?,
    nextDueDate: json['nextDueDate'] as String?,
        active: json['active'] as bool? ?? true,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );

  @override
  String toString() => jsonEncode(toJson());
}
