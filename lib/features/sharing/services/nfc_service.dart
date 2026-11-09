import 'dart:async';
import 'package:nfc_manager/nfc_manager.dart';

enum NfcSessionState {
  idle,
  checking,
  waitingForTag,
  writing,
  reading,
  success,
  unsupported,
  disabled,
  error,
}

class NfcService {
  static final NfcService instance = NfcService._init();
  NfcService._init();

  /// Kiểm tra thiết bị có hỗ trợ NFC phần cứng hay không
  Future<bool> isNfcSupported() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Ghi đường dẫn danh thiếp (NDEF URI) lên thẻ NFC
  Future<void> writeCardUriToTag({
    required String cardUrl,
    required void Function(NfcSessionState state, String? message) onStateChanged,
  }) async {
    final supported = await isNfcSupported();

    if (!supported) {
      onStateChanged(NfcSessionState.unsupported, 'Thiết bị không hỗ trợ phần cứng NFC hoặc đang chạy máy ảo');
      return;
    }

    onStateChanged(NfcSessionState.waitingForTag, 'Vui lòng chạm lưng điện thoại vào thẻ NFC...');

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          onStateChanged(NfcSessionState.writing, 'Đang ghi dữ liệu danh thiếp vào thẻ...');

          final ndef = Ndef.from(tag);
          if (ndef == null) {
            onStateChanged(NfcSessionState.error, 'Thẻ NFC này không hỗ trợ định dạng chuẩn NDEF');
            await NfcManager.instance.stopSession();
            return;
          }

          if (!ndef.isWritable) {
            onStateChanged(NfcSessionState.error, 'Thẻ NFC ở chế độ chỉ đọc (Read-only), không thể ghi đè');
            await NfcManager.instance.stopSession();
            return;
          }

          final uriRecord = NdefRecord.createUri(Uri.parse(cardUrl));
          final message = NdefMessage([uriRecord]);

          try {
            await ndef.write(message);
            onStateChanged(NfcSessionState.success, 'Đã ghi danh thiếp thành công lên thẻ NFC!');
            await NfcManager.instance.stopSession();
          } catch (e) {
            onStateChanged(NfcSessionState.error, 'Ghi thẻ thất bại: $e');
            await NfcManager.instance.stopSession(errorMessage: e.toString());
          }
        },
      );
    } catch (e) {
      onStateChanged(NfcSessionState.error, 'Lỗi phiên NFC: $e');
    }
  }

  /// Đọc dữ liệu từ thẻ NFC
  Future<void> readTag({
    required void Function(NfcSessionState state, String? payload, String? message) onResult,
  }) async {
    final supported = await isNfcSupported();

    if (!supported) {
      onResult(NfcSessionState.unsupported, null, 'Thiết bị không hỗ trợ phần cứng NFC');
      return;
    }

    onResult(NfcSessionState.waitingForTag, null, 'Vui lòng chạm thẻ NFC vào mặt lưng điện thoại...');

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          onResult(NfcSessionState.reading, null, 'Đang đọc thẻ NFC...');

          final ndef = Ndef.from(tag);
          if (ndef == null || ndef.cachedMessage == null) {
            onResult(NfcSessionState.error, null, 'Không tìm thấy dữ liệu NDEF trên thẻ');
            await NfcManager.instance.stopSession();
            return;
          }

          String? extractedUrl;
          for (final record in ndef.cachedMessage!.records) {
            // Kiểm tra record URI
            if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
              final payload = record.payload;
              if (payload.isNotEmpty) {
                // Byte đầu tiên là mã tiền tố URI (0x04 = https://)
                final uriString = String.fromCharCodes(payload.sublist(1));
                if (payload[0] == 0x04) {
                  extractedUrl = 'https://$uriString';
                } else if (payload[0] == 0x03) {
                  extractedUrl = 'http://$uriString';
                } else {
                  extractedUrl = uriString;
                }
                break;
              }
            }
          }

          if (extractedUrl != null) {
            onResult(NfcSessionState.success, extractedUrl, 'Đã đọc danh thiếp thành công!');
          } else {
            onResult(NfcSessionState.error, null, 'Không tìm thấy liên kết danh thiếp trên thẻ');
          }

          await NfcManager.instance.stopSession();
        },
      );
    } catch (e) {
      onResult(NfcSessionState.error, null, 'Lỗi phiên NFC: $e');
    }
  }

  /// Hủy phiên làm việc NFC đang chạy
  Future<void> stopSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
  }

  /// Giả lập thao tác NFC (Dành cho máy ảo hoặc thiết bị không có phần cứng NFC)
  Future<void> simulateMockNfcWrite({
    required String cardUrl,
    required void Function(NfcSessionState state, String? message) onStateChanged,
  }) async {
    onStateChanged(NfcSessionState.waitingForTag, 'Mô phỏng NFC: Đang chờ chạm thẻ...');
    await Future.delayed(const Duration(milliseconds: 1200));

    onStateChanged(NfcSessionState.writing, 'Mô phỏng NFC: Đang ghi đường dẫn $cardUrl...');
    await Future.delayed(const Duration(milliseconds: 1000));

    onStateChanged(NfcSessionState.success, 'Mô phỏng NFC thành công: Đã ghi thẻ NFC giả lập!');
  }
}
