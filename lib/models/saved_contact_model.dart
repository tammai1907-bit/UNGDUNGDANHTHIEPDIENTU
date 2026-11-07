import 'dart:convert';

class SavedContactModel {
  final String id;
  final String fullName;
  final String jobTitle;
  final String company;
  final String phone;
  final String email;
  final String website;
  final String address;
  final String bio;
  final String? avatarUrl;
  final Map<String, String> socialLinks;
  final List<String> tags; // ['Khách hàng', 'VIP', 'Đối tác']
  final String notes; // Contextual notes (Ghi chú ngữ cảnh)
  final double? latitude; // Tọa độ GPS gặp gỡ
  final double? longitude;
  final String? locationName; // Tên địa điểm ví dụ "Quận 1, TP.HCM"
  final DateTime metAt; // Thời điểm gặp gỡ/quét mã
  final DateTime? reminderDate; // Lời nhắc tương tác
  final bool isFavorite;
  final String? rawVCard;

  const SavedContactModel({
    required this.id,
    required this.fullName,
    required this.jobTitle,
    required this.company,
    required this.phone,
    required this.email,
    this.website = '',
    this.address = '',
    this.bio = '',
    this.avatarUrl,
    this.socialLinks = const {},
    this.tags = const [],
    this.notes = '',
    this.latitude,
    this.longitude,
    this.locationName,
    required this.metAt,
    this.reminderDate,
    this.isFavorite = false,
    this.rawVCard,
  });

  SavedContactModel copyWith({
    String? id,
    String? fullName,
    String? jobTitle,
    String? company,
    String? phone,
    String? email,
    String? website,
    String? address,
    String? bio,
    String? avatarUrl,
    Map<String, String>? socialLinks,
    List<String>? tags,
    String? notes,
    double? latitude,
    double? longitude,
    String? locationName,
    DateTime? metAt,
    DateTime? reminderDate,
    bool? isFavorite,
    String? rawVCard,
  }) {
    return SavedContactModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      socialLinks: socialLinks ?? this.socialLinks,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      metAt: metAt ?? this.metAt,
      reminderDate: reminderDate ?? this.reminderDate,
      isFavorite: isFavorite ?? this.isFavorite,
      rawVCard: rawVCard ?? this.rawVCard,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'jobTitle': jobTitle,
      'company': company,
      'phone': phone,
      'email': email,
      'website': website,
      'address': address,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'socialLinks': jsonEncode(socialLinks),
      'tags': jsonEncode(tags),
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'metAt': metAt.toIso8601String(),
      'reminderDate': reminderDate?.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
      'rawVCard': rawVCard,
    };
  }

  factory SavedContactModel.fromMap(Map<String, dynamic> map) {
    Map<String, String> parsedSocial = {};
    if (map['socialLinks'] != null) {
      try {
        final decoded = jsonDecode(map['socialLinks'] as String);
        if (decoded is Map) {
          parsedSocial = decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      } catch (_) {}
    }

    List<String> parsedTags = [];
    if (map['tags'] != null) {
      try {
        final decoded = jsonDecode(map['tags'] as String);
        if (decoded is List) {
          parsedTags = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return SavedContactModel(
      id: map['id'] as String,
      fullName: map['fullName'] as String? ?? '',
      jobTitle: map['jobTitle'] as String? ?? '',
      company: map['company'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      website: map['website'] as String? ?? '',
      address: map['address'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      socialLinks: parsedSocial,
      tags: parsedTags,
      notes: map['notes'] as String? ?? '',
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      locationName: map['locationName'] as String?,
      metAt: map['metAt'] != null
          ? DateTime.tryParse(map['metAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      reminderDate: map['reminderDate'] != null
          ? DateTime.tryParse(map['reminderDate'] as String)
          : null,
      isFavorite: (map['isFavorite'] is int ? map['isFavorite'] == 1 : map['isFavorite'] == true),
      rawVCard: map['rawVCard'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory SavedContactModel.fromJson(String source) =>
      SavedContactModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  String toVCard() {
    if (rawVCard != null && rawVCard!.isNotEmpty) {
      return rawVCard!;
    }
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    buffer.writeln('FN:$fullName');
    buffer.writeln('N:$fullName;;;;');
    if (company.isNotEmpty) buffer.writeln('ORG:$company');
    if (jobTitle.isNotEmpty) buffer.writeln('TITLE:$jobTitle');
    if (phone.isNotEmpty) buffer.writeln('TEL;TYPE=CELL:$phone');
    if (email.isNotEmpty) buffer.writeln('EMAIL;TYPE=INTERNET:$email');
    if (website.isNotEmpty) buffer.writeln('URL:$website');
    if (address.isNotEmpty) buffer.writeln('ADR;TYPE=WORK:;;$address;;;;');
    if (notes.isNotEmpty) buffer.writeln('NOTE:$notes');
    buffer.writeln('END:VCARD');
    return buffer.toString();
  }
}
