import 'package:flutter/material.dart';
import '../services/nfc_service.dart';

enum NfcOperationMode {
  read,
  write,
}

class NfcSheet extends StatefulWidget {
  final NfcOperationMode mode;
  final String? dataToWrite;
  final Function(String data, String type)? onDataReceived;

  const NfcSheet({
    super.key,
    required this.mode,
    this.dataToWrite,
    this.onDataReceived,
  });

  @override
  State<NfcSheet> createState() => _NfcSheetState();
}

class _NfcSheetState extends State<NfcSheet> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _statusMessage = 'Đang sẵn sàng kết nối NFC...';
  bool _isSuccess = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initNfcProcess();
  }

  void _initNfcProcess() {
    if (widget.mode == NfcOperationMode.read) {
      _statusMessage = 'Hãy đưa mặt lưng điện thoại lại gần thẻ NFC hoặc thiết bị khác...';
      NfcService.instance.startNfcReading(
        onTagDiscovered: (data, type) {
          if (!mounted) return;
          setState(() {
            _isSuccess = true;
            _statusMessage = 'Đã đọc thành công dữ liệu $type!';
          });
          widget.onDataReceived?.call(data, type);
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context);
          });
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _isError = true;
            _statusMessage = err;
          });
        },
      );
    } else {
      _statusMessage = 'Đưa thẻ NFC (NDEF Writable) lại gần để ghi danh thiếp...';
      if (widget.dataToWrite != null) {
        NfcService.instance.writeToNfcTag(
          dataToWrite: widget.dataToWrite!,
          onSuccess: () {
            if (!mounted) return;
            setState(() {
              _isSuccess = true;
              _statusMessage = 'Ghi danh thiếp vào thẻ NFC thành công!';
            });
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) Navigator.pop(context);
            });
          },
          onError: (err) {
            if (!mounted) return;
            setState(() {
              _isError = true;
              _statusMessage = err;
            });
          },
        );
      }
    }
  }

  /// Giả lập chạm NFC (HCE Demo) để thuyết trình đồ án khi chạy Emulator
  void _simulateNfcTap() {
    setState(() {
      _isSuccess = true;
      _statusMessage = widget.mode == NfcOperationMode.read
          ? 'Mô phỏng NFC thành công: Đã nhận danh thiếp đối tác!'
          : 'Mô phỏng NFC thành công: Đã truyền danh thiếp qua HCE!';
    });

    if (widget.mode == NfcOperationMode.read) {
      const demoVCard = '''BEGIN:VCARD
VERSION:3.0
FN:Trần Đình Trọng
ORG:Công nghệ NFC Việt Nam
TITLE:Kỹ sư IoT & Nhúng
TEL;TYPE=CELL:0978123456
EMAIL:trong.tran@nfcvn.com
URL:https://nfcvn.com
NOTE:Chạm kết nối nhanh qua NFC HCE
END:VCARD''';
      widget.onDataReceived?.call(demoVCard, 'vCard');
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    NfcService.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // NFC Waves Icon
          ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.15).animate(_animController),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSuccess
                    ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                    : (_isError ? Colors.red.withValues(alpha: 0.1) : const Color(0xFF2563EB).withValues(alpha: 0.1)),
              ),
              child: Icon(
                _isSuccess ? Icons.check_circle : (_isError ? Icons.error_outline : Icons.nfc),
                size: 56,
                color: _isSuccess
                    ? const Color(0xFF16A34A)
                    : (_isError ? Colors.red : const Color(0xFF2563EB)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.mode == NfcOperationMode.read ? 'Sẵn Sàng Đọc Thẻ NFC' : 'Sẵn Sàng Ghi Thẻ NFC',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _isError ? Colors.red : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),

          // Simulation Button for Testing/Grading Demo
          OutlinedButton.icon(
            onPressed: _simulateNfcTap,
            icon: const Icon(Icons.touch_app, size: 18),
            label: const Text('Mô Phỏng Chạm NFC (HCE Demo)', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy bỏ', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }
}
