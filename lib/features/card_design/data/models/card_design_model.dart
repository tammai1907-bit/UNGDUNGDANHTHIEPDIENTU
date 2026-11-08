import '../../domain/entities/card_design.dart';

/// Extension model hỗ trợ chuyển đổi dữ liệu CardDesign với Firestore/JSON
extension CardDesignModel on CardDesign {
  Map<String, dynamic> toMap() {
    return {
      'templateId': templateId,
      'primaryColorHex': primaryColorHex,
      'secondaryColorHex': secondaryColorHex,
      'backgroundColorHex': backgroundColorHex,
      'textColorHex': textColorHex,
      'fontFamily': fontFamily,
      'cornerRadius': cornerRadius,
      'showBanner': showBanner,
    };
  }

  static CardDesign fromMap(Map<String, dynamic> map) {
    return CardDesign.fromHex(
      templateId: map['templateId'] as String? ?? 'classic',
      primaryColorHex: map['primaryColorHex'] as String? ?? '#1E88E5',
      secondaryColorHex: map['secondaryColorHex'] as String? ?? '#0D47A1',
      backgroundColorHex: map['backgroundColorHex'] as String? ?? '#FFFFFF',
      textColorHex: map['textColorHex'] as String? ?? '#212121',
      fontFamily: map['fontFamily'] as String? ?? 'Roboto',
      cornerRadius: (map['cornerRadius'] as num?)?.toDouble() ?? 16.0,
      showBanner: map['showBanner'] as bool? ?? true,
    );
  }
}
