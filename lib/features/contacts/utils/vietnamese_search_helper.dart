/// Tiện ích chuẩn hóa và tìm kiếm chuỗi tiếng Việt không dấu
class VietnameseSearchHelper {
  static const _vietnameseChars = 'aAeEoOuUiIdDyY';
  static final _vietnameseRegex = <RegExp>[
    RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'),
    RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'),
    RegExp(r'[èéẹẻẽêềếệểễ]'),
    RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'),
    RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'),
    RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'),
    RegExp(r'[ùúụủũưừứựửữ]'),
    RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'),
    RegExp(r'[ìíịỉĩ]'),
    RegExp(r'[ÌÍỊỈĨ]'),
    RegExp(r'[đ]'),
    RegExp(r'[Đ]'),
    RegExp(r'[ỳýỵỷỹ]'),
    RegExp(r'[ỲÝỴỶỸ]'),
  ];

  /// Chuyển đổi chuỗi tiếng Việt có dấu thành không dấu chữ thường
  static String removeDiacritics(String str) {
    var result = str;
    for (var i = 0; i < _vietnameseRegex.length; i++) {
      result = result.replaceAll(_vietnameseRegex[i], _vietnameseChars[i]);
    }
    return result.toLowerCase().trim();
  }

  /// So khớp tìm kiếm không dấu
  static bool matches(String source, String query) {
    if (query.trim().isEmpty) return true;
    final normalizedSource = removeDiacritics(source);
    final normalizedQuery = removeDiacritics(query);
    return normalizedSource.contains(normalizedQuery);
  }
}
