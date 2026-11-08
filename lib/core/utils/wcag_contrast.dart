import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Tiện ích kiểm tra độ tương phản màu theo tiêu chuẩn WCAG 2.1
class WcagContrast {
  WcagContrast._();

  /// Tính độ sáng tương đối (Relative Luminance) theo chuẩn WCAG 2.1
  static double calculateRelativeLuminance(Color color) {
    double transform(double channel) {
      final c = channel / 255.0;
      if (c <= 0.04045) {
        return c / 12.92;
      } else {
        return math.pow((c + 0.055) / 1.055, 2.4).toDouble();
      }
    }

    final argb = color.toARGB32();
    final r = transform(((argb >> 16) & 0xFF).toDouble());
    final g = transform(((argb >> 8) & 0xFF).toDouble());
    final b = transform((argb & 0xFF).toDouble());

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Tính tỉ lệ tương phản (Contrast Ratio) giữa 2 màu (1.0 đến 21.0)
  static double calculateContrastRatio(Color foreground, Color background) {
    final l1 = calculateRelativeLuminance(foreground);
    final l2 = calculateRelativeLuminance(background);

    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Đánh giá độ tương phản theo chuẩn WCAG AA
  /// - Chữ thường (Normal text): Tối thiểu 4.5:1
  /// - Chữ lớn/tiêu đề (Large text): Tối thiểu 3.0:1
  static WcagEvaluation evaluate({
    required Color textColor,
    required Color backgroundColor,
  }) {
    final ratio = calculateContrastRatio(textColor, backgroundColor);
    final passesNormal = ratio >= 4.5;
    final passesLarge = ratio >= 3.0;

    String? warning;
    if (!passesLarge) {
      warning =
          'Độ tương phản rất thấp (${ratio.toStringAsFixed(2)}:1). Chữ sẽ rất khó đọc trên nền này!';
    } else if (!passesNormal) {
      warning =
          'Độ tương phản (${ratio.toStringAsFixed(2)}:1) đạt mức chữ lớn nhưng chữ nhỏ có thể khó nhìn.';
    }

    return WcagEvaluation(
      ratio: ratio,
      passesNormalText: passesNormal,
      passesLargeText: passesLarge,
      warningMessage: warning,
    );
  }
}

/// Kết quả đánh giá WCAG
class WcagEvaluation {
  final double ratio;
  final bool passesNormalText;
  final bool passesLargeText;
  final String? warningMessage;

  const WcagEvaluation({
    required this.ratio,
    required this.passesNormalText,
    required this.passesLargeText,
    this.warningMessage,
  });

  bool get isCompliant => passesNormalText;
}
