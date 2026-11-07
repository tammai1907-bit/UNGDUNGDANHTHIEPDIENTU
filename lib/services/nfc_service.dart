import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  static final NfcService instance = NfcService._init();
  NfcService._init();

  /// Kiểm tra thiết bị có hỗ trợ NFC và đã bật NFC hay không
  Future<bool> isNfcAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (e) {
      debugPrint('NFC error: $e');
      return false;
    }
  }

  /// Bắt đầu lắng nghe và đọc dữ liệu từ thẻ NFC
  Future<void> startNfcReading({
    required Function(String data, String type) onTagDiscovered,
    required Function(String error) onError,
  }) async {
    final available = await isNfcAvailable();
    if (!available) {
      onError('Thiết bị không hỗ trợ NFC hoặc chưa bật tính năng NFC.');
      return;
    }

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final ndef = Ndef.from(tag);
            if (ndef == null) {
              onError('Thẻ NFC này không chứa định dạng NDEF chuẩn.');
              await stopSession();
              return;
            }

            final cachedMessage = ndef.cachedMessage;
            if (cachedMessage == null || cachedMessage.records.isEmpty) {
              onError('Thẻ NFC trống, chưa có dữ liệu danh thiếp.');
              await stopSession();
              return;
            }

            // Duyệt qua các records
            for (var record in cachedMessage.records) {
              final payload = record.payload;

              // 1. Kiểm tra nếu là URI Record
              if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
                  listEquals(record.type, [0x55])) { // 'U'
                // Byte đầu tiên là URI Identifier Code
                final uriPrefix = _decodeUriPrefix(payload.first);
                final uriString = uriPrefix + utf8.decode(payload.sublist(1));
                onTagDiscovered(uriString, 'URL');
                await stopSession();
                return;
              }

              // 2. Kiểm tra nếu là Text hoặc Mime vCard
              final text = utf8.decode(payload, allowMalformed: true);
              if (text.contains('BEGIN:VCARD') || text.contains('END:VCARD')) {
                onTagDiscovered(text, 'vCard');
                await stopSession();
                return;
              } else if (text.contains('http://') || text.contains('https://')) {
                onTagDiscovered(text, 'URL');
                await stopSession();
                return;
              } else {
                onTagDiscovered(text, 'Text');
                await stopSession();
                return;
              }
            }
          } catch (e) {
            onError('Lỗi khi đọc thẻ NFC: $e');
            await stopSession();
          }
        },
      );
    } catch (e) {
      onError('Không thể khởi tạo phiên NFC: $e');
    }
  }

  /// Ghi dữ liệu danh thiếp (URL hoặc vCard text) vào thẻ NFC
  Future<void> writeToNfcTag({
    required String dataToWrite,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    final available = await isNfcAvailable();
    if (!available) {
      onError('Thiết bị không hỗ trợ NFC hoặc chưa bật tính năng NFC.');
      return;
    }

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            onError('Thẻ không hỗ trợ chuẩn NDEF.');
            await stopSession();
            return;
          }

          if (!ndef.isWritable) {
            onError('Thẻ NFC này đã bị khóa (Read-only), không thể ghi đè.');
            await stopSession();
            return;
          }

          NdefRecord record;
          if (dataToWrite.startsWith('http://') || dataToWrite.startsWith('https://')) {
            // Ghi URI record
            record = NdefRecord.createUri(Uri.parse(dataToWrite));
          } else {
            // Ghi MIME vCard record hoặc Text
            record = NdefRecord.createMime(
              'text/vcard',
              Uint8List.fromList(utf8.encode(dataToWrite)),
            );
          }

          final message = NdefMessage([record]);

          try {
            await ndef.write(message);
            onSuccess();
          } catch (e) {
            onError('Ghi thẻ thất bại: $e');
          } finally {
            await stopSession();
          }
        },
      );
    } catch (e) {
      onError('Lỗi kích hoạt ghi NFC: $e');
    }
  }

  /// Dừng phiên NFC
  Future<void> stopSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
  }

  String _decodeUriPrefix(int prefixByte) {
    switch (prefixByte) {
      case 0x01:
        return 'http://www.';
      case 0x02:
        return 'https://www.';
      case 0x03:
        return 'http://';
      case 0x04:
        return 'https://';
      case 0x05:
        return 'tel:';
      case 0x06:
        return 'mailto:';
      default:
        return '';
    }
  }
}
