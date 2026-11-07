import 'dart:convert';
import '../config/app_constants.dart';

class BusinessCardModel {
  final String id;
  final String userId;
  final String cardName; // 'Công việc chính thức', 'Freelancer', 'Cá nhân'
  final String fullName;
  final String jobTitle;
  final String company;
  final String phone;
  final String email;
  final String website;
  final String address;
  final String bio;
  final String? avatarUrl;
  final String? logoUrl;
  final String? coverUrl;
  final Map<String, String> socialLinks; // 'linkedin', 'facebook', 'zalo', 'github', 'twitter'
  final CardTemplateType template;
  final String themeColorId;
  final List<String> skills;
  final String? portfolioUrl;
  final bool isDefault;
  final bool isPrivatePhone; // Chế độ bảo mật
  final bool isPrivateEmail; // Chế độ bảo mật
  final DateTime createdAt;
  final DateTime updatedAt;

  const BusinessCardModel({
    required this.id,
    required this.userId,
    required this.cardName,
    required this.fullName,
    required this.jobTitle,
    required this.company,
    required this.phone,
    required this.email,
    this.website = '',
    this.address = '',
    this.bio = '',
    this.avatarUrl,
    this.logoUrl,
    this.coverUrl,
    this.socialLinks = const {},
    this.template = CardTemplateType.modern,
    this.themeColorId = 'navy_blue',
    this.skills = const [],
    this.portfolioUrl,
    this.isDefault = false,
    this.isPrivatePhone = false,
    this.isPrivateEmail = false,
    required this.createdAt,
    required this.updatedAt,
  });

  BusinessCardModel copyWith({
    String? id,
    String? userId,
    String? cardName,
    String? fullName,
    String? jobTitle,
    String? company,
    String? phone,
    String? email,
    String? website,
    String? address,
    String? bio,
    String? avatarUrl,
    String? logoUrl,
    String? coverUrl,
    Map<String, String>? socialLinks,
    CardTemplateType? template,
    String? themeColorId,
    List<String>? skills,
    String? portfolioUrl,
    bool? isDefault,
    bool? isPrivatePhone,
    bool? isPrivateEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessCardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardName: cardName ?? this.cardName,
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      socialLinks: socialLinks ?? this.socialLinks,
      template: template ?? this.template,
      themeColorId: themeColorId ?? this.themeColorId,
      skills: skills ?? this.skills,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      isDefault: isDefault ?? this.isDefault,
      isPrivatePhone: isPrivatePhone ?? this.isPrivatePhone,
      isPrivateEmail: isPrivateEmail ?? this.isPrivateEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cardName': cardName,
      'fullName': fullName,
      'jobTitle': jobTitle,
      'company': company,
      'phone': phone,
      'email': email,
      'website': website,
      'address': address,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'logoUrl': logoUrl,
      'coverUrl': coverUrl,
      'socialLinks': jsonEncode(socialLinks),
      'template': template.name,
      'themeColorId': themeColorId,
      'skills': jsonEncode(skills),
      'portfolioUrl': portfolioUrl,
      'isDefault': isDefault ? 1 : 0,
      'isPrivatePhone': isPrivatePhone ? 1 : 0,
      'isPrivateEmail': isPrivateEmail ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BusinessCardModel.fromMap(Map<String, dynamic> map) {
    Map<String, String> parsedSocial = {};
    if (map['socialLinks'] != null) {
      try {
        final decoded = jsonDecode(map['socialLinks'] as String);
        if (decoded is Map) {
          parsedSocial = decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      } catch (_) {}
    }

    List<String> parsedSkills = [];
    if (map['skills'] != null) {
      try {
        final decoded = jsonDecode(map['skills'] as String);
        if (decoded is List) {
          parsedSkills = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    CardTemplateType parsedTemplate = CardTemplateType.modern;
    if (map['template'] != null) {
      try {
        parsedTemplate = CardTemplateType.values.byName(map['template'] as String);
      } catch (_) {
        parsedTemplate = CardTemplateType.modern;
      }
    }

    return BusinessCardModel(
      id: map['id'] as String,
      userId: map['userId'] as String? ?? 'user_default',
      cardName: map['cardName'] as String? ?? 'Danh thiếp của tôi',
      fullName: map['fullName'] as String? ?? '',
      jobTitle: map['jobTitle'] as String? ?? '',
      company: map['company'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      website: map['website'] as String? ?? '',
      address: map['address'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      logoUrl: map['logoUrl'] as String?,
      coverUrl: map['coverUrl'] as String?,
      socialLinks: parsedSocial,
      template: parsedTemplate,
      themeColorId: map['themeColorId'] as String? ?? 'navy_blue',
      skills: parsedSkills,
      portfolioUrl: map['portfolioUrl'] as String?,
      isDefault: (map['isDefault'] is int ? map['isDefault'] == 1 : map['isDefault'] == true),
      isPrivatePhone: (map['isPrivatePhone'] is int ? map['isPrivatePhone'] == 1 : map['isPrivatePhone'] == true),
      isPrivateEmail: (map['isPrivateEmail'] is int ? map['isPrivateEmail'] == 1 : map['isPrivateEmail'] == true),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory BusinessCardModel.fromJson(String source) =>
      BusinessCardModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Xuất chuỗi định dạng chuẩn vCard 3.0 (Offline-first QR / NFC / File .vcf)
  String toVCard() {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    buffer.writeln('FN:$fullName');
    
    // Tách tên họ
    final parts = fullName.trim().split(' ');
    if (parts.length > 1) {
      final lastName = parts.first;
      final firstName = parts.sublist(1).join(' ');
      buffer.writeln('N:$lastName;$firstName;;;');
    } else {
      buffer.writeln('N:$fullName;;;;');
    }

    if (company.isNotEmpty) {
      buffer.writeln('ORG:$company');
    }
    if (jobTitle.isNotEmpty) {
      buffer.writeln('TITLE:$jobTitle');
    }
    if (phone.isNotEmpty && !isPrivatePhone) {
      buffer.writeln('TEL;TYPE=CELL,VOICE:$phone');
    }
    if (email.isNotEmpty && !isPrivateEmail) {
      buffer.writeln('EMAIL;TYPE=INTERNET,PREF:$email');
    }
    if (website.isNotEmpty) {
      buffer.writeln('URL:$website');
    }
    if (address.isNotEmpty) {
      buffer.writeln('ADR;TYPE=WORK:;;$address;;;;');
    }
    if (bio.isNotEmpty) {
      buffer.writeln('NOTE:$bio');
    }
    
    // Thêm các liên kết mạng xã hội nếu có
    socialLinks.forEach((platform, link) {
      if (link.isNotEmpty) {
        buffer.writeln('X-SOCIALPROFILE;TYPE=$platform:$link');
      }
    });

    buffer.writeln('REV:${DateTime.now().toIso8601String()}');
    buffer.writeln('END:VCARD');
    return buffer.toString();
  }

  /// Chuỗi JSON thu gọn để dùng cho QR Online hoặc truyền Deep Link
  String toSharePayload() {
    return jsonEncode({
      'type': 'digital_business_card',
      'id': id,
      'fn': fullName,
      'title': jobTitle,
      'org': company,
      'tel': isPrivatePhone ? '' : phone,
      'em': isPrivateEmail ? '' : email,
      'web': website,
      'addr': address,
      'bio': bio,
      'social': socialLinks,
      'tpl': template.name,
      'color': themeColorId,
    });
  }
}
