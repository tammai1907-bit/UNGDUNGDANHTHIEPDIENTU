import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/foundation.dart';
import '../models/saved_contact_model.dart';

class ContactService {
  static final ContactService instance = ContactService._init();
  ContactService._init();

  /// Xin quyền truy cập danh bạ thiết bị
  Future<bool> requestContactsPermission() async {
    try {
      return await FlutterContacts.requestPermission(readonly: false);
    } catch (e) {
      debugPrint('Contacts permission error: $e');
      return false;
    }
  }

  /// Lưu danh thiếp trực tiếp vào Danh bạ gốc của điện thoại
  Future<bool> saveCardToNativeContacts({
    required String fullName,
    required String phone,
    String? email,
    String? company,
    String? jobTitle,
    String? website,
    String? address,
    String? note,
  }) async {
    final hasPermission = await requestContactsPermission();
    if (!hasPermission) return false;

    try {
      final newContact = Contact();
      
      // Tách tên họ
      final parts = fullName.trim().split(' ');
      if (parts.length > 1) {
        newContact.name.first = parts.sublist(1).join(' ');
        newContact.name.last = parts.first;
      } else {
        newContact.name.first = fullName;
      }

      if (phone.isNotEmpty) {
        newContact.phones = [Phone(phone, label: PhoneLabel.mobile)];
      }

      if (email != null && email.isNotEmpty) {
        newContact.emails = [Email(email, label: EmailLabel.work)];
      }

      if (company != null && company.isNotEmpty) {
        newContact.organizations = [
          Organization(
            company: company,
            title: jobTitle ?? '',
          ),
        ];
      }

      if (website != null && website.isNotEmpty) {
        newContact.websites = [Website(website, label: WebsiteLabel.homepage)];
      }

      if (address != null && address.isNotEmpty) {
        newContact.addresses = [Address(address, label: AddressLabel.work)];
      }

      if (note != null && note.isNotEmpty) {
        newContact.notes = [Note(note)];
      }

      await newContact.insert();
      return true;
    } catch (e) {
      debugPrint('Error inserting native contact: $e');
      return false;
    }
  }

  /// Phân tích chuỗi vCard thô thành SavedContactModel
  static SavedContactModel parseVCard(String vcardText) {
    String fn = '';
    String org = '';
    String title = '';
    String tel = '';
    String email = '';
    String url = '';
    String adr = '';
    String note = '';

    final lines = vcardText.split(RegExp(r'\r\n|\r|\n'));
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('FN:')) {
        fn = trimmed.substring(3).trim();
      } else if (trimmed.startsWith('ORG:')) {
        org = trimmed.substring(4).trim();
      } else if (trimmed.startsWith('TITLE:')) {
        title = trimmed.substring(6).trim();
      } else if (trimmed.startsWith('TEL') && trimmed.contains(':')) {
        tel = trimmed.substring(trimmed.indexOf(':') + 1).trim();
      } else if (trimmed.startsWith('EMAIL') && trimmed.contains(':')) {
        email = trimmed.substring(trimmed.indexOf(':') + 1).trim();
      } else if (trimmed.startsWith('URL:') || (trimmed.startsWith('URL;') && trimmed.contains(':'))) {
        url = trimmed.substring(trimmed.indexOf(':') + 1).trim();
      } else if (trimmed.startsWith('ADR') && trimmed.contains(':')) {
        final rawAdr = trimmed.substring(trimmed.indexOf(':') + 1);
        adr = rawAdr.replaceAll(';', ' ').trim();
      } else if (trimmed.startsWith('NOTE:')) {
        note = trimmed.substring(5).trim();
      }
    }

    return SavedContactModel(
      id: 'vcard_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fn.isNotEmpty ? fn : 'Danh thiếp mới',
      jobTitle: title,
      company: org,
      phone: tel,
      email: email,
      website: url,
      address: adr,
      notes: note,
      metAt: DateTime.now(),
      rawVCard: vcardText,
    );
  }
}
