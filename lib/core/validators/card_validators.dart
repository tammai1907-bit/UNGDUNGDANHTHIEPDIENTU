import '../../features/card_design/domain/entities/social_link.dart';
import '../constants/card_constants.dart';

/// Bộ kiểm tra tính hợp lệ và chuẩn hóa dữ liệu cho danh thiếp
class CardValidators {
  CardValidators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Đầu số mạng di động Việt Nam: 03, 05, 07, 08, 09
  static final RegExp _phoneCleanRegExp = RegExp(r'[\s.\-()]');
  static final RegExp _phoneVnRegExp = RegExp(r'^(?:0|\+84)(?:3|5|7|8|9)[0-9]{8}$');

  /// Kiểm tra trường bắt buộc
  static String? validateRequired(String? value, {String fieldName = 'Trường này'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  /// Kiểm tra email
  static String? validateEmail(String? value, {bool isRequired = false}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return 'Vui lòng nhập địa chỉ email';
      return null;
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Địa chỉ email không đúng định dạng (VD: ten@congty.vn)';
    }
    return null;
  }

  /// Chuẩn hóa số điện thoại Việt Nam về định dạng chuẩn 0xxxxxxxxx
  static String normalizePhoneVN(String input) {
    var cleaned = input.replaceAll(_phoneCleanRegExp, '').trim();
    if (cleaned.startsWith('+84')) {
      cleaned = '0${cleaned.substring(3)}';
    } else if (cleaned.startsWith('84') && cleaned.length == 11) {
      cleaned = '0${cleaned.substring(2)}';
    }
    return cleaned;
  }

  /// Kiểm tra số điện thoại Việt Nam
  static String? validatePhoneVN(String? value, {bool isRequired = false}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return 'Vui lòng nhập số điện thoại';
      return null;
    }
    final normalized = normalizePhoneVN(value);
    if (!_phoneVnRegExp.hasMatch(normalized)) {
      return 'Số điện thoại không hợp lệ (cần 10 chữ số, đầu số 03, 05, 07, 08, 09)';
    }
    return null;
  }

  /// Kiểm tra độ dài phần giới thiệu
  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length > CardConstants.maxBioLength) {
      return 'Giới thiệu không được vượt quá ${CardConstants.maxBioLength} ký tự (${value.length}/${CardConstants.maxBioLength})';
    }
    return null;
  }

  /// Kiểm tra URL chung và domain phù hợp với từng mạng xã hội
  static String? validateUrl(String? value, {SocialLinkType? expectedType, bool isRequired = false}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return 'Vui lòng nhập đường dẫn hoặc tên tài khoản';
      return null;
    }

    final trimmed = value.trim();

    // Đối với các link phone/sms/email: kiểm tra theo validator riêng
    if (expectedType == SocialLinkType.phone || expectedType == SocialLinkType.sms) {
      return validatePhoneVN(trimmed, isRequired: isRequired);
    }
    if (expectedType == SocialLinkType.email) {
      return validateEmail(trimmed, isRequired: isRequired);
    }

    // Nếu người dùng nhập username ngắn cho FB / GitHub / LinkedIn / Zalo -> coi là hợp lệ
    final hasProtocol = trimmed.startsWith('http://') || trimmed.startsWith('https://');
    final containsSlash = trimmed.contains('/');

    // Nếu chỉ nhập username đơn thuần (không có domain và protocol)
    if (!hasProtocol && !containsSlash && expectedType != null && expectedType != SocialLinkType.website) {
      if (RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(trimmed)) {
        return null; // Username hợp lệ
      }
    }

    // Nếu là Zalo và người dùng nhập SĐT
    if (expectedType == SocialLinkType.zalo && validatePhoneVN(trimmed) == null) {
      return null;
    }

    // Chuẩn hóa thành URL đầy đủ để parse
    final urlToTest = hasProtocol ? trimmed : 'https://$trimmed';
    final uri = Uri.tryParse(urlToTest);

    if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) {
      return 'Đường dẫn liên kết không đúng định dạng';
    }

    // Kiểm tra domain tương ứng
    final host = uri.host.toLowerCase();
    switch (expectedType) {
      case SocialLinkType.facebook:
        if (!host.contains('facebook.com') && !host.contains('fb.com')) {
          return 'Đường dẫn phải thuộc miền facebook.com (VD: facebook.com/username)';
        }
        break;
      case SocialLinkType.linkedin:
        if (!host.contains('linkedin.com')) {
          return 'Đường dẫn phải thuộc miền linkedin.com (VD: linkedin.com/in/username)';
        }
        break;
      case SocialLinkType.github:
        if (!host.contains('github.com')) {
          return 'Đường dẫn phải thuộc miền github.com (VD: github.com/username)';
        }
        break;
      case SocialLinkType.zalo:
        if (!host.contains('zalo.me')) {
          return 'Đường dẫn Zalo phải là số điện thoại hoặc thuộc zalo.me (VD: zalo.me/0901234567)';
        }
        break;
      default:
        break;
    }

    return null;
  }

  /// Tự động chuẩn hóa liên kết mạng xã hội sang format URL hoặc scheme chuẩn
  static String normalizeSocialUrl(SocialLinkType type, String input) {
    final raw = input.trim();
    if (raw.isEmpty) return '';

    switch (type) {
      case SocialLinkType.phone:
        final normalizedPhone = normalizePhoneVN(raw);
        return 'tel:$normalizedPhone';

      case SocialLinkType.sms:
        final normalizedPhone = normalizePhoneVN(raw);
        return 'sms:$normalizedPhone';

      case SocialLinkType.email:
        final cleanEmail = raw.replaceFirst(RegExp(r'^mailto:', caseSensitive: false), '').trim();
        return 'mailto:$cleanEmail';

      case SocialLinkType.zalo:
        // Nếu là số điện thoại
        if (validatePhoneVN(raw) == null) {
          final phone = normalizePhoneVN(raw);
          return 'https://zalo.me/$phone';
        }
        if (raw.startsWith('http://') || raw.startsWith('https://')) {
          return raw;
        }
        if (raw.startsWith('zalo.me/')) {
          return 'https://$raw';
        }
        return 'https://zalo.me/$raw';

      case SocialLinkType.facebook:
        if (raw.startsWith('http://') || raw.startsWith('https://')) {
          return raw;
        }
        if (raw.startsWith('facebook.com/') || raw.startsWith('fb.com/')) {
          return 'https://$raw';
        }
        return 'https://facebook.com/$raw';

      case SocialLinkType.linkedin:
        if (raw.startsWith('http://') || raw.startsWith('https://')) {
          return raw;
        }
        if (raw.startsWith('linkedin.com/')) {
          return 'https://$raw';
        }
        return 'https://linkedin.com/in/$raw';

      case SocialLinkType.github:
        if (raw.startsWith('http://') || raw.startsWith('https://')) {
          return raw;
        }
        if (raw.startsWith('github.com/')) {
          return 'https://$raw';
        }
        return 'https://github.com/$raw';

      case SocialLinkType.website:
        if (raw.startsWith('http://') || raw.startsWith('https://')) {
          return raw;
        }
        return 'https://$raw';
    }
  }
}
