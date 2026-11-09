import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/features/contacts/utils/vietnamese_search_helper.dart';

void main() {
  group('VietnameseSearchHelper Tests', () {
    test('Xóa dấu tiếng Việt chính xác', () {
      expect(VietnameseSearchHelper.removeDiacritics('Mai Văn Tâm'), 'mai van tam');
      expect(VietnameseSearchHelper.removeDiacritics('Nguyễn Thị Lan'), 'nguyen thi lan');
      expect(VietnameseSearchHelper.removeDiacritics('Đà Nẵng - Thủ Đức'), 'da nang - thu duc');
      expect(VietnameseSearchHelper.removeDiacritics('Hội Thảo Quốc Tế 2026'), 'hoi thao quoc te 2026');
    });

    test('Tìm kiếm không dấu khớp với chuỗi gốc có dấu', () {
      expect(VietnameseSearchHelper.matches('Mai Văn Tâm', 'tam'), isTrue);
      expect(VietnameseSearchHelper.matches('Mai Văn Tâm', 'van'), isTrue);
      expect(VietnameseSearchHelper.matches('Mai Văn Tâm', 'TÂM'), isTrue);
      expect(VietnameseSearchHelper.matches('Tập đoàn Công nghệ VinTech', 'cong nghe'), isTrue);
      expect(VietnameseSearchHelper.matches('Khu Công nghệ cao, TP. Thủ Đức', 'thu duc'), isTrue);
      expect(VietnameseSearchHelper.matches('Nguyễn Văn An', 'tam'), isFalse);
    });
  });
}
