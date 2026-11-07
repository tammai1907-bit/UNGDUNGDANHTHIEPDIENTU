import 'package:flutter/material.dart';
import '../models/saved_contact_model.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class WalletProvider extends ChangeNotifier {
  List<SavedContactModel> _contacts = [];
  String _selectedTag = 'Tất cả';
  String _searchQuery = '';
  bool _isLoading = false;

  List<SavedContactModel> get contacts => _contacts;
  String get selectedTag => _selectedTag;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  /// Danh sách contacts sau khi áp dụng bộ lọc tag và tìm kiếm
  List<SavedContactModel> get filteredContacts {
    return _contacts.where((c) {
      // 1. Lọc theo Tag
      final matchTag = _selectedTag == 'Tất cả' || c.tags.contains(_selectedTag);

      // 2. Lọc theo từ khóa tìm kiếm
      if (!matchTag) return false;
      if (_searchQuery.trim().isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      return c.fullName.toLowerCase().contains(query) ||
          c.jobTitle.toLowerCase().contains(query) ||
          c.company.toLowerCase().contains(query) ||
          c.phone.toLowerCase().contains(query) ||
          c.email.toLowerCase().contains(query) ||
          (c.locationName?.toLowerCase().contains(query) ?? false) ||
          c.notes.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();

    _contacts = await DatabaseService.instance.getAllSavedContacts();

    _isLoading = false;
    notifyListeners();
  }

  void filterByTag(String tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Thêm liên hệ mới nhận được (tự động đính kèm GPS & Địa điểm gặp gỡ nếu có)
  Future<void> addContactWithLocation(SavedContactModel contact, {bool fetchGps = true}) async {
    SavedContactModel finalContact = contact;

    if (fetchGps && contact.locationName == null) {
      final loc = await LocationService.instance.getCurrentMeetingLocation();
      if (loc != null) {
        finalContact = contact.copyWith(
          latitude: loc.latitude,
          longitude: loc.longitude,
          locationName: loc.locationName,
        );
      }
    }

    await DatabaseService.instance.insertSavedContact(finalContact);
    await loadContacts();
  }

  Future<void> updateContact(SavedContactModel contact) async {
    await DatabaseService.instance.updateSavedContact(contact);
    await loadContacts();
  }

  Future<void> deleteContact(String id) async {
    await DatabaseService.instance.deleteSavedContact(id);
    await loadContacts();
  }

  Future<void> toggleFavorite(SavedContactModel contact) async {
    final updated = contact.copyWith(isFavorite: !contact.isFavorite);
    await updateContact(updated);
  }

  Future<void> updateContextNotes(String id, String notes, {DateTime? reminder}) async {
    final index = _contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      final updated = _contacts[index].copyWith(notes: notes, reminderDate: reminder);
      await updateContact(updated);
    }
  }
}
