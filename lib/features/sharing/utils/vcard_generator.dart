import 'dart:io';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../card_design/domain/entities/business_card.dart';
import '../../card_design/domain/entities/social_link.dart';

/// Bộ sinh chuỗi và tệp vCard 3.0 chuẩn quốc tế
class VCardGenerator {
  /// Sinh chuỗi vCard 3.0 từ BusinessCard
  static String generateVCardString(BusinessCard card) {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');

    // Họ tên
    buffer.writeln('FN:${card.fullName}');
    final nameParts = card.fullName.trim().split(' ');
    if (nameParts.length > 1) {
      final lastName = nameParts.last;
      final firstName = nameParts.sublist(0, nameParts.length - 1).join(' ');
      buffer.writeln('N:$lastName;$firstName;;;');
    } else {
      buffer.writeln('N:${card.fullName};;;;');
    }

    // Công ty & Chức danh
    if (card.company.isNotEmpty) {
      buffer.writeln('ORG:${card.company}');
    }
    if (card.jobTitle.isNotEmpty) {
      buffer.writeln('TITLE:${card.jobTitle}');
    }

    // Số điện thoại
    if (card.phone != null && card.phone!.isNotEmpty) {
      buffer.writeln('TEL;TYPE=CELL,VOICE:${card.phone}');
    }

    // Email
    if (card.email != null && card.email!.isNotEmpty) {
      buffer.writeln('EMAIL;TYPE=INTERNET,PREF:${card.email}');
    }

    // Website
    if (card.website != null && card.website!.isNotEmpty) {
      buffer.writeln('URL:${card.website}');
    }

    // Địa chỉ
    if (card.address != null && card.address!.isNotEmpty) {
      buffer.writeln('ADR;TYPE=WORK:;;${card.address};;;;');
    }

    // Giới thiệu (Bio)
    if (card.bio != null && card.bio!.isNotEmpty) {
      buffer.writeln('NOTE:${card.bio}');
    }

    // Mạng xã hội trong vCard
    for (final link in card.socialLinks.where((l) => l.isVisible)) {
      switch (link.type) {
        case SocialLinkType.phone:
          if (link.value != card.phone) {
            buffer.writeln('TEL;TYPE=VOICE:${link.value}');
          }
          break;
        case SocialLinkType.email:
          if (link.value != card.email) {
            buffer.writeln('EMAIL;TYPE=INTERNET:${link.value}');
          }
          break;
        default:
          buffer.writeln('URL;TYPE=${link.type.name.toUpperCase()}:${link.value}');
          break;
      }
    }

    buffer.writeln('END:VCARD');
    return buffer.toString();
  }

  /// Xuất chuỗi vCard thành tệp .vcf và trả về đường dẫn tệp
  static Future<File> saveVCardToFile(BusinessCard card) async {
    final vcardString = generateVCardString(card);
    final tempDir = await getTemporaryDirectory();
    final fileName = '${card.fullName.replaceAll(RegExp(r'\s+'), '_')}_contact.vcf';
    final file = File('${tempDir.path}/$fileName');
    return await file.writeAsString(vcardString);
  }

  /// Chia sẻ tệp vCard qua hệ điều hành (Share Sheet)
  static Future<void> shareVCard(BusinessCard card) async {
    final file = await saveVCardToFile(card);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/vcard')],
      subject: 'Danh thiếp: ${card.fullName}',
      text: 'Danh thiếp điện tử của ${card.fullName} (${card.jobTitle})',
    );
  }

  /// Lưu trực tiếp vào danh bạ của điện thoại
  static Future<bool> saveToDeviceContacts(BusinessCard card) async {
    try {
      final permission = await FlutterContacts.requestPermission();
      if (!permission) return false;

      final contact = Contact();

      // Tên
      final nameParts = card.fullName.trim().split(' ');
      if (nameParts.length > 1) {
        contact.name.last = nameParts.last;
        contact.name.first = nameParts.sublist(0, nameParts.length - 1).join(' ');
      } else {
        contact.name.first = card.fullName;
      }

      // Công ty & Chức danh
      if (card.company.isNotEmpty || card.jobTitle.isNotEmpty) {
        contact.organizations.add(Organization(
          company: card.company,
          title: card.jobTitle,
        ));
      }

      // Số điện thoại
      if (card.phone != null && card.phone!.isNotEmpty) {
        contact.phones.add(Phone(card.phone!, label: PhoneLabel.mobile));
      }

      // Email
      if (card.email != null && card.email!.isNotEmpty) {
        contact.emails.add(Email(card.email!, label: EmailLabel.work));
      }

      // Website
      if (card.website != null && card.website!.isNotEmpty) {
        contact.websites.add(Website(card.website!, label: WebsiteLabel.homepage));
      }

      // Địa chỉ
      if (card.address != null && card.address!.isNotEmpty) {
        contact.addresses.add(Address(card.address!, label: AddressLabel.work));
      }

      // Ghi chú
      if (card.bio != null && card.bio!.isNotEmpty) {
        contact.notes.add(Note(card.bio!));
      }

      // Mạng xã hội
      for (final link in card.socialLinks.where((l) => l.isVisible)) {
        if (link.type != SocialLinkType.phone && link.type != SocialLinkType.email) {
          contact.websites.add(Website(link.value, label: WebsiteLabel.other));
        }
      }

      await contact.insert();
      return true;
    } catch (_) {
      return false;
    }
  }
}
