import '../../../card_design/domain/entities/business_card.dart';

/// Thực thể danh thiếp được lưu vào Ví danh bạ (Mini CRM)
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
  final String? savedLocation;
  final String? source; // 'Quét mã QR', 'Chạm thẻ NFC', 'Nhập thủ công'
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
    this.savedLocation,
    this.source,
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
    String? savedLocation,
    String? source,
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
      savedLocation: savedLocation ?? this.savedLocation,
      source: source ?? this.source,
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
      'savedLocation': savedLocation,
      'source': source,
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
      tags:
          (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      notes: map['notes'] as String?,
      savedLocation: map['savedLocation'] as String?,
      source: map['source'] as String?,
      savedAt: map['savedAt'] != null
          ? DateTime.parse(map['savedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Khởi tạo SavedContact từ BusinessCard nhận được từ module Thành viên 3
  factory SavedContact.fromBusinessCard(
    BusinessCard card, {
    String currentUserId = 'user_current',
    List<String> tags = const ['Đối tác'],
    String? notes,
    String? source = 'Quét mã QR',
    String? savedLocation,
  }) {
    return SavedContact(
      id: 'contact_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: currentUserId,
      originalCardId: card.id,
      fullName: card.fullName,
      jobTitle: card.jobTitle,
      company: card.company,
      phone: card.phone,
      email: card.email,
      website: card.website,
      address: card.address,
      avatarUrl: card.avatarUrl,
      tags: tags,
      notes: notes,
      source: source,
      savedLocation: savedLocation,
      savedAt: DateTime.now(),
    );
  }

  /// Khởi tạo SavedContact từ chuỗi vCard quét được từ Camera QR
  factory SavedContact.fromVCard(
    String vcardText, {
    String currentUserId = 'user_current',
    List<String> tags = const ['Sự kiện'],
    String? notes,
    String? source = 'Quét mã QR',
    String? savedLocation,
  }) {
    String fn = '';
    String org = '';
    String title = '';
    String tel = '';
    String email = '';
    String url = '';
    String adr = '';
    String note = '';

    final lines = vcardText.split(RegExp(r'\r\n|\r|\n'));
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('FN:')) {
        fn = trimmed.substring(3).trim();
      } else if (trimmed.startsWith('ORG:')) {
        org = trimmed.substring(4).trim();
      } else if (trimmed.startsWith('TITLE:')) {
        title = trimmed.substring(6).trim();
      } else if (trimmed.startsWith('TEL') && trimmed.contains(':')) {
        tel = trimmed.substring(trimmed.indexOf(':') + 1).trim();
      } else if (trimmed.startsWith('EMAIL') && trimmed.contains(':')) {
        email = trimmed.substring(trimmed.indexOf(':') + 1).trim();
      } else if (trimmed.startsWith('URL:') ||
          (trimmed.startsWith('URL;') && trimmed.contains(':'))) {
        url = trimmed.substring(trimmed.indexOf(':') + 1).trim();
      } else if (trimmed.startsWith('ADR') && trimmed.contains(':')) {
        final rawAdr = trimmed.substring(trimmed.indexOf(':') + 1);
        adr = rawAdr.replaceAll(';', ' ').trim();
      } else if (trimmed.startsWith('NOTE:')) {
        note = trimmed.substring(5).trim();
      }
    }

    return SavedContact(
      id: 'contact_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: currentUserId,
      fullName: fn.isNotEmpty ? fn : 'Liên hệ mới',
      jobTitle: title.isNotEmpty ? title : null,
      company: org.isNotEmpty ? org : null,
      phone: tel.isNotEmpty ? tel : null,
      email: email.isNotEmpty ? email : null,
      website: url.isNotEmpty ? url : null,
      address: adr.isNotEmpty ? adr : null,
      tags: tags,
      notes: notes ?? (note.isNotEmpty ? note : null),
      source: source,
      savedLocation: savedLocation,
      savedAt: DateTime.now(),
    );
  }
}
