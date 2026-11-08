import '../../../../core/utils/result.dart';
import '../entities/business_card.dart';

/// Interface quản lý lưu trữ và truy vấn danh thiếp
abstract class CardRepository {
  /// Theo dõi danh sách thẻ của một người dùng theo thời gian thực (reactive stream)
  Stream<List<BusinessCard>> watchCards(String userId);

  /// Lấy danh sách thẻ 1 lần
  Future<Result<List<BusinessCard>>> getCards(String userId);

  /// Lấy chi tiết 1 thẻ bằng ID
  Future<Result<BusinessCard>> getCardById({
    required String userId,
    required String cardId,
  });

  /// Tạo danh thiếp mới
  Future<Result<void>> createCard(BusinessCard card);

  /// Cập nhật danh thiếp hiện có
  Future<Result<void>> updateCard(BusinessCard card);

  /// Xóa danh thiếp theo ID
  Future<Result<void>> deleteCard({
    required String userId,
    required String cardId,
  });

  /// Nhân bản một danh thiếp có sẵn (tạo bản sao "Bản sao của ...")
  Future<Result<BusinessCard>> duplicateCard({
    required String userId,
    required String cardId,
    required String newId,
  });

  /// Đặt một danh thiếp làm mặc định và hủy mặc định của các thẻ khác
  Future<Result<void>> setDefaultCard({
    required String userId,
    required String cardId,
  });
}
