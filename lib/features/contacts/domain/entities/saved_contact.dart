/// Thực thể danh thiếp được lưu vào Ví danh bạ
class SavedContact {
  final String id;
  final String ownerId;
  final String? originalCardId;
  final String fullName;
  final String? jobTitle;
  final String? company;
  final String? phone;
  final String? email;
  final String? website;
  final String? address;
  final String? avatarUrl;
  final List<String> tags;
  final String? notes;
  final DateTime savedAt;

  const SavedContact({
    required this.id,
    required this.ownerId,
    this.originalCardId,
    required this.fullName,
    this.jobTitle,
    this.company,
    this.phone,
    this.email,
    this.website,
    this.address,
    this.avatarUrl,
    this.tags = const [],
    this.notes,
    required this.savedAt,
  });

  SavedContact copyWith({
    String? id,
    String? ownerId,
    String? originalCardId,
    String? fullName,
    String? jobTitle,
    String? company,
    String? phone,
    String? email,
    String? website,
    String? address,
    String? avatarUrl,
    List<String>? tags,
    String? notes,
    DateTime? savedAt,
  }) {
    return SavedContact(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      originalCardId: originalCardId ?? this.originalCardId,
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'originalCardId': originalCardId,
      'fullName': fullName,
      'jobTitle': jobTitle,
      'company': company,
      'phone': phone,
      'email': email,
      'website': website,
      'address': address,
      'avatarUrl': avatarUrl,
      'tags': tags,
      'notes': notes,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedContact.fromMap(Map<String, dynamic> map) {
    return SavedContact(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      originalCardId: map['originalCardId'] as String?,
      fullName: map['fullName'] as String,
      jobTitle: map['jobTitle'] as String?,
      company: map['company'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      address: map['address'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      notes: map['notes'] as String?,
      savedAt: map['savedAt'] != null
          ? DateTime.parse(map['savedAt'] as String)
          : DateTime.now(),
    );
  }
}
