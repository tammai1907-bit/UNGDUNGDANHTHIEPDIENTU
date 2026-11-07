import 'package:flutter/material.dart';
import '../models/business_card_model.dart';
import '../models/analytics_model.dart';
import '../services/database_service.dart';

class CardProvider extends ChangeNotifier {
  List<BusinessCardModel> _myCards = [];
  BusinessCardModel? _activeCard;
  CardAnalyticsModel? _activeAnalytics;
  bool _isLoading = false;

  List<BusinessCardModel> get myCards => _myCards;
  BusinessCardModel? get activeCard => _activeCard;
  CardAnalyticsModel? get activeAnalytics => _activeAnalytics;
  bool get isLoading => _isLoading;

  Future<void> loadMyCards() async {
    _isLoading = true;
    notifyListeners();

    _myCards = await DatabaseService.instance.getAllProfiles();
    if (_myCards.isNotEmpty) {
      // Chọn thẻ mặc định hoặc thẻ đầu tiên
      _activeCard = _myCards.firstWhere((c) => c.isDefault, orElse: () => _myCards.first);
      await loadAnalyticsForCard(_activeCard!.id);
    } else {
      _activeCard = null;
      _activeAnalytics = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setActiveCard(BusinessCardModel card) {
    _activeCard = card;
    loadAnalyticsForCard(card.id);
    notifyListeners();
  }

  Future<void> loadAnalyticsForCard(String cardId) async {
    _activeAnalytics = await DatabaseService.instance.getAnalytics(cardId);
    notifyListeners();
  }

  Future<void> addCard(BusinessCardModel card) async {
    await DatabaseService.instance.insertProfile(card);
    await loadMyCards();
  }

  Future<void> updateCard(BusinessCardModel card) async {
    await DatabaseService.instance.updateProfile(card);
    await loadMyCards();
  }

  Future<void> deleteCard(String cardId) async {
    await DatabaseService.instance.deleteProfile(cardId);
    await loadMyCards();
  }

  Future<void> setDefaultCard(String cardId) async {
    await DatabaseService.instance.setDefaultProfile(cardId);
    await loadMyCards();
  }

  Future<void> togglePrivacy({required String cardId, bool? hidePhone, bool? hideEmail}) async {
    final index = _myCards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      final old = _myCards[index];
      final updated = old.copyWith(
        isPrivatePhone: hidePhone ?? old.isPrivatePhone,
        isPrivateEmail: hideEmail ?? old.isPrivateEmail,
      );
      await DatabaseService.instance.updateProfile(updated);
      await loadMyCards();
    }
  }

  Future<void> recordInteraction({
    required String cardId,
    bool isView = false,
    bool isSave = false,
    bool isQr = false,
    bool isNfc = false,
    String? platform,
  }) async {
    await DatabaseService.instance.recordCardInteraction(
      cardId: cardId,
      isView: isView,
      isSave: isSave,
      isQr: isQr,
      isNfc: isNfc,
      clickedPlatform: platform,
    );
    if (_activeCard?.id == cardId) {
      await loadAnalyticsForCard(cardId);
    }
  }
}
