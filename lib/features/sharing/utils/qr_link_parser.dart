import '../../../config/app_constants.dart';

class CardShareInfo {
  final String ownerId;
  final String cardId;

  const CardShareInfo({required this.ownerId, required this.cardId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardShareInfo &&
          runtimeType == other.runtimeType &&
          ownerId == other.ownerId &&
          cardId == other.cardId;

  @override
  int get hashCode => ownerId.hashCode ^ cardId.hashCode;

  @override
  String toString() => 'CardShareInfo(ownerId: $ownerId, cardId: $cardId)';
}

/// Tiện ích phân tích và trích xuất dữ liệu từ mã QR hoặc đường dẫn chia sẻ
class QrLinkParser {
  /// Giải mã chuỗi URL hoặc dữ liệu QR thành CardShareInfo
  static CardShareInfo? parse(String rawData) {
    final trimmed = rawData.trim();
    if (trimmed.isEmpty) return null;

    try {
      final uri = Uri.parse(trimmed);

      // Định dạng chuẩn: https://card.maitam1907.dev/c/{ownerId}/{cardId}
      // hoặc bất kỳ host nào có path dạng /c/{ownerId}/{cardId}
      final segments = uri.pathSegments;
      if (segments.length >= 3 && segments[0] == 'c') {
        final ownerId = segments[1];
        final cardId = segments[2];
        if (ownerId.isNotEmpty && cardId.isNotEmpty) {
          return CardShareInfo(ownerId: ownerId, cardId: cardId);
        }
      }

      // Hỗ trợ custom scheme: card://usr_123/card_456 hoặc card://c/{ownerId}/{cardId}
      if (uri.scheme == 'card') {
        if (uri.host.isNotEmpty && segments.isNotEmpty) {
          return CardShareInfo(ownerId: uri.host, cardId: segments.first);
        } else if (segments.length >= 2) {
          return CardShareInfo(ownerId: segments[0], cardId: segments[1]);
        }
      }

      // Hỗ trợ định dạng tham số: ?ownerId=...&cardId=...
      final queryOwner = uri.queryParameters['ownerId'] ?? uri.queryParameters['owner'];
      final queryCard = uri.queryParameters['cardId'] ?? uri.queryParameters['card'];
      if (queryOwner != null && queryCard != null) {
        return CardShareInfo(ownerId: queryOwner, cardId: queryCard);
      }
    } catch (_) {}

    return null;
  }

  /// Kiểm tra một đường dẫn có phải là link danh thiếp hợp lệ không
  static bool isValidCardUrl(String url) {
    return parse(url) != null;
  }

  /// Sinh đường dẫn chia sẻ chuẩn
  static String buildUrl({required String ownerId, required String cardId}) {
    return AppConstants.buildCardShareUrl(ownerId: ownerId, cardId: cardId);
  }
}
