import '../../domain/entities/social_link.dart';

/// Extension model hỗ trợ chuyển đổi dữ liệu SocialLink với Firestore/JSON
extension SocialLinkModel on SocialLink {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'value': value,
      'label': label,
      'order': order,
      'isVisible': isVisible,
    };
  }

  static SocialLink fromMap(Map<String, dynamic> map) {
    return SocialLink(
      id: map['id'] as String? ?? '',
      type: SocialLinkType.fromString(map['type'] as String? ?? 'website'),
      value: map['value'] as String? ?? '',
      label: map['label'] as String?,
      order: (map['order'] as num?)?.toInt() ?? 0,
      isVisible: map['isVisible'] as bool? ?? true,
    );
  }
}
