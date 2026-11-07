import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';

class OcrResult {
  final String rawText;
  final String fullName;
  final String jobTitle;
  final String company;
  final String phone;
  final String email;
  final String website;
  final String address;

  const OcrResult({
    required this.rawText,
    required this.fullName,
    required this.jobTitle,
    required this.company,
    required this.phone,
    required this.email,
    required this.website,
    required this.address,
  });
}

class OcrService {
  static final OcrService instance = OcrService._init();
  OcrService._init();

  /// Quét văn bản từ đường dẫn file ảnh
  Future<OcrResult> processBusinessCardImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      return parseBusinessCardText(recognizedText.text);
    } catch (e) {
      debugPrint('ML Kit OCR error: $e');
      // Trả về kết quả rỗng hoặc fallback
      return parseBusinessCardText('');
    }
  }

  /// Thuật toán phân tích cú pháp (Heuristics & Regex) bóc tách thông tin danh thiếp
  static OcrResult parseBusinessCardText(String fullText) {
    if (fullText.trim().isEmpty) {
      return const OcrResult(
        rawText: '',
        fullName: '',
        jobTitle: '',
        company: '',
        phone: '',
        email: '',
        website: '',
        address: '',
      );
    }

    final lines = fullText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String detectedPhone = '';
    String detectedEmail = '';
    String detectedWebsite = '';
    String detectedCompany = '';
    String detectedJobTitle = '';
    String detectedAddress = '';
    String detectedName = '';

    // Regex Phone: Nhận diện SĐT Việt Nam & Quốc tế (+84, 09xx, 08xx, 07xx, 03xx, có dấu chấm hoặc gạch nối)
    final phoneRegex = RegExp(r'(?:(?:\+84|0)[1-9])(?:[\s.-]?\d{2,4}){2,3}');
    // Regex Email
    final emailRegex = RegExp(r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+');
    // Regex Website
    final websiteRegex = RegExp(r'(?:https?:\/\/)?(?:www\.)?[a-zA-Z0-9-]+\.(?:com|vn|net|org|io|dev|ai)(?:\/[^\s]*)?');

    // Từ khóa nhận diện chức danh
    final titleKeywords = [
      'giám đốc', 'director', 'manager', 'trưởng phòng', 'engineer', 'kỹ sư',
      'developer', 'designer', 'ceo', 'cto', 'cmo', 'cfo', 'consultant',
      'chuyên viên', 'lead', 'architect', 'phó giám đốc', 'founder'
    ];

    // Từ khóa nhận diện công ty
    final companyKeywords = [
      'công ty', 'company', 'corp', 'corporation', 'tập đoàn', 'jsc',
      'ltd', 'tnhh', 'group', 'solutions', 'technologies', 'studio', 'agency'
    ];

    // Từ khóa nhận diện địa chỉ
    final addressKeywords = [
      'đường', 'phố', 'quận', 'huyện', 'tp', 'thành phố', 'tỉnh', 'tầng',
      'tòa nhà', 'street', 'district', 'floor', 'building', 'vietnam', 'hà nội', 'hcm'
    ];

    for (var line in lines) {
      final lower = line.toLowerCase();

      // 1. Tìm Email
      if (detectedEmail.isEmpty && emailRegex.hasMatch(line)) {
        detectedEmail = emailRegex.firstMatch(line)?.group(0) ?? '';
        continue;
      }

      // 2. Tìm Phone
      if (detectedPhone.isEmpty && phoneRegex.hasMatch(line)) {
        detectedPhone = phoneRegex.firstMatch(line)?.group(0) ?? '';
        continue;
      }

      // 3. Tìm Website
      if (detectedWebsite.isEmpty && websiteRegex.hasMatch(line)) {
        final match = websiteRegex.firstMatch(line)?.group(0) ?? '';
        if (!match.contains('@')) {
          detectedWebsite = match;
          continue;
        }
      }

      // 4. Tìm Công ty
      if (detectedCompany.isEmpty && companyKeywords.any((k) => lower.contains(k))) {
        detectedCompany = line;
        continue;
      }

      // 5. Tìm Chức vụ
      if (detectedJobTitle.isEmpty && titleKeywords.any((k) => lower.contains(k))) {
        detectedJobTitle = line;
        continue;
      }

      // 6. Tìm Địa chỉ
      if (detectedAddress.isEmpty && addressKeywords.any((k) => lower.contains(k))) {
        detectedAddress = line;
        continue;
      }
    }

    // 7. Nhận diện Họ và Tên (Dòng thường ở nửa trên, độ dài vừa phải, không chứa số/kí tự đặc biệt)
    for (var line in lines) {
      if (line == detectedCompany ||
          line == detectedJobTitle ||
          line == detectedAddress ||
          line == detectedPhone ||
          line == detectedEmail ||
          line == detectedWebsite) {
        continue;
      }

      // Không chứa ký tự số hoặc @ / http
      final wordCount = line.split(' ').length;
      if (!line.contains(RegExp(r'[0-9@:/]')) && (wordCount >= 2 && wordCount <= 5)) {
        detectedName = line;
        break;
      }
    }

    // Nếu vẫn chưa tìm thấy name, lấy dòng đầu tiên không phải company
    if (detectedName.isEmpty && lines.isNotEmpty) {
      detectedName = lines.first;
    }

    return OcrResult(
      rawText: fullText,
      fullName: detectedName,
      jobTitle: detectedJobTitle,
      company: detectedCompany,
      phone: detectedPhone,
      email: detectedEmail,
      website: detectedWebsite,
      address: detectedAddress,
    );
  }
}

