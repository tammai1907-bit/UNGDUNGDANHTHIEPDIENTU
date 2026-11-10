import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../contacts/domain/entities/saved_contact.dart';
import '../../../contacts/presentation/providers/contact_providers.dart';
import '../../services/nfc_service.dart';
import '../../utils/qr_link_parser.dart';

enum NfcMode { write, read }

class NfcExchangeScreen extends ConsumerStatefulWidget {
  final String cardUrl;
  final String cardName;

  const NfcExchangeScreen({
    super.key,
    required this.cardUrl,
    required this.cardName,
  });

  @override
  ConsumerState<NfcExchangeScreen> createState() => _NfcExchangeScreenState();
}

class _NfcExchangeScreenState extends ConsumerState<NfcExchangeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  NfcMode _currentMode = NfcMode.write;
  NfcSessionState _state = NfcSessionState.idle;
  String? _statusMessage;
  bool _isMockMode = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startCurrentNfcProcess();
  }

  @override
  void dispose() {
    _animController.dispose();
    NfcService.instance.stopSession();
    super.dispose();
  }

  Future<void> _startCurrentNfcProcess() async {
    final supported = await NfcService.instance.isNfcSupported();

    if (!supported) {
      if (mounted) {
        setState(() {
          _state = NfcSessionState.unsupported;
          _statusMessage =
              'Thiết bị không hỗ trợ phần cứng NFC hoặc đang chạy máy ảo.\nBạn có thể nhấn nút "Mô phỏng NFC" bên dưới để kiểm thử tính năng.';
        });
      }
      return;
    }

    if (_currentMode == NfcMode.write) {
      _startWriteProcess();
    } else {
      _startReadProcess();
    }
  }

  void _switchMode(NfcMode mode) {
    if (_currentMode == mode) return;
    NfcService.instance.stopSession();
    setState(() {
      _currentMode = mode;
      _state = NfcSessionState.idle;
      _statusMessage = null;
      _isMockMode = false;
    });
    _startCurrentNfcProcess();
  }

  void _startWriteProcess() {
    setState(() {
      _state = NfcSessionState.waitingForTag;
      _statusMessage = 'Vui lòng chạm thẻ NFC vào mặt lưng điện thoại để ghi...';
    });

    NfcService.instance.writeCardUriToTag(
      cardUrl: widget.cardUrl,
      onStateChanged: (state, message) {
        if (mounted) {
          setState(() {
            _state = state;
            _statusMessage = message;
          });
        }
      },
    );
  }

  void _startReadProcess() {
    setState(() {
      _state = NfcSessionState.waitingForTag;
      _statusMessage = 'Vui lòng chạm thẻ NFC hoặc điện thoại đối tác vào mặt lưng...';
    });

    NfcService.instance.readTag(
      onResult: (state, payload, message) {
        if (mounted) {
          setState(() {
            _state = state;
            _statusMessage = message;
          });
          if (state == NfcSessionState.success && payload != null) {
            _handleReadData(payload);
          }
        }
      },
    );
  }

  void _runMockSimulation() {
    setState(() {
      _isMockMode = true;
      _state = NfcSessionState.waitingForTag;
    });

    if (_currentMode == NfcMode.write) {
      NfcService.instance.simulateMockNfcWrite(
        cardUrl: widget.cardUrl,
        onStateChanged: (state, message) {
          if (mounted) {
            setState(() {
              _state = state;
              _statusMessage = message;
            });
          }
        },
      );
    } else {
      NfcService.instance.simulateMockNfcRead(
        mockPayload: widget.cardUrl,
        onResult: (state, payload, message) {
          if (mounted) {
            setState(() {
              _state = state;
              _statusMessage = message;
            });
            if (state == NfcSessionState.success && payload != null) {
              _handleReadData(payload);
            }
          }
        },
      );
    }
  }

  void _handleReadData(String payload) {
    // 1. Nếu là đường dẫn danh thiếp của ứng dụng
    final cardInfo = QrLinkParser.parse(payload);
    if (cardInfo != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.contact_mail_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text('Đã Đọc Danh Thiếp'),
            ],
          ),
          content: Text('Đã nhận diện danh thiếp từ NFC:\n\n$payload'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Xem & Lưu Vào Ví'),
              onPressed: () {
                Navigator.pop(ctx);
                context.push(
                  '/public-card?ownerId=${cardInfo.ownerId}&cardId=${cardInfo.cardId}&source=nfc',
                );
              },
            ),
          ],
        ),
      );
      return;
    }

    // 2. Nếu là vCard thô
    if (payload.toUpperCase().contains('BEGIN:VCARD')) {
      final parsedContact = SavedContact.fromVCard(
        payload,
        source: 'Chạm thẻ NFC',
        tags: const ['NFC'],
      );

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.nfc_rounded, color: Color(0xFFEA580C)),
                  SizedBox(width: 8),
                  Text(
                    'Đã Nhận vCard Qua NFC!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Họ và tên: ${parsedContact.fullName}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (parsedContact.jobTitle != null)
                Text('Chức vụ: ${parsedContact.jobTitle}'),
              if (parsedContact.company != null)
                Text('Công ty: ${parsedContact.company}'),
              if (parsedContact.phone != null)
                Text('Số điện thoại: ${parsedContact.phone}'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                  icon: const Icon(Icons.bookmark_add_rounded),
                  label: const Text('Lưu Ngay Vào Ví Danh Bạ'),
                  onPressed: () async {
                    final res = await ref
                        .read(contactControllerProvider.notifier)
                        .addContact(parsedContact);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: res.isSuccess
                              ? const Color(0xFF16A34A)
                              : Colors.red,
                          content: Text(
                            res.isSuccess
                                ? 'Đã lưu danh thiếp "${parsedContact.fullName}" vào Ví!'
                                : 'Lỗi khi lưu danh thiếp: ${res.errorOrNull}',
                          ),
                        ),
                      );
                      if (res.isSuccess) context.go('/contacts');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // 3. Nội dung văn bản / liên kết khác
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dữ Liệu Thẻ NFC'),
        content: Text('Nội dung đọc được từ thẻ:\n\n$payload'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_state) {
      case NfcSessionState.success:
        return const Color(0xFF16A34A);
      case NfcSessionState.error:
      case NfcSessionState.unsupported:
        return const Color(0xFFDC2626);
      case NfcSessionState.writing:
      case NfcSessionState.reading:
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF2563EB);
    }
  }

  IconData _getStatusIcon() {
    switch (_state) {
      case NfcSessionState.success:
        return Icons.check_circle_rounded;
      case NfcSessionState.error:
        return Icons.error_rounded;
      case NfcSessionState.unsupported:
        return Icons.nfc_outlined;
      case NfcSessionState.writing:
        return Icons.upload_rounded;
      case NfcSessionState.reading:
        return Icons.download_rounded;
      default:
        return Icons.contactless_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao Tiếp Phần Cứng NFC'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thanh chọn chế độ Ghi thẻ hoặc Đọc thẻ
              SegmentedButton<NfcMode>(
                segments: const [
                  ButtonSegment<NfcMode>(
                    value: NfcMode.write,
                    icon: Icon(Icons.upload_rounded, size: 18),
                    label: Text('Ghi Vào Thẻ'),
                  ),
                  ButtonSegment<NfcMode>(
                    value: NfcMode.read,
                    icon: Icon(Icons.download_rounded, size: 18),
                    label: Text('Đọc Thẻ Đối Tác'),
                  ),
                ],
                selected: {_currentMode},
                onSelectionChanged: (newSelection) {
                  _switchMode(newSelection.first);
                },
              ),

              const SizedBox(height: 20),

              // Thông tin thẻ đang chọn (chỉ hiện khi ở chế độ Ghi)
              if (_currentMode == NfcMode.write)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.credit_card_rounded, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.cardName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors, color: Color(0xFFEA580C)),
                      SizedBox(width: 8),
                      Text(
                        'Chế độ thu thập danh thiếp qua NFC',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEA580C)),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Animation Sóng NFC
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_state == NfcSessionState.waitingForTag ||
                          _state == NfcSessionState.writing ||
                          _state == NfcSessionState.reading)
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: List.generate(3, (index) {
                                final value =
                                    (_animController.value + index / 3.0) % 1.0;
                                return Container(
                                  width: 80 + value * 120,
                                  height: 80 + value * 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: statusColor.withValues(
                                        alpha: (1.0 - value) * 0.6,
                                      ),
                                      width: 3,
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor.withValues(alpha: 0.12),
                          border: Border.all(color: statusColor, width: 2),
                        ),
                        child: Icon(
                          _getStatusIcon(),
                          size: 44,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Trạng thái văn bản
              Text(
                _state == NfcSessionState.success
                    ? (_currentMode == NfcMode.write ? 'Ghi Thẻ Thành Công!' : 'Đọc Thẻ Thành Công!')
                    : (_state == NfcSessionState.unsupported
                        ? 'Chưa Có Phần Cứng NFC'
                        : (_currentMode == NfcMode.write ? 'Sẵn Sàng Ghi Thẻ' : 'Sẵn Sàng Đọc Thẻ')),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusMessage ??
                    (_currentMode == NfcMode.write
                        ? 'Đặt mặt lưng điện thoại gần thẻ NFC trắng để ghi dữ liệu.'
                        : 'Chạm thẻ NFC của đối tác vào mặt lưng điện thoại để đọc.'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),

              if (_currentMode == NfcMode.write) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.cardUrl,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2563EB),
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              const Spacer(),

              // Nút Mock Simulation
              if (_state == NfcSessionState.unsupported || _isMockMode) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _runMockSimulation,
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(
                      _currentMode == NfcMode.write
                          ? 'Mô Phỏng Ghi Thẻ NFC (Mock Test)'
                          : 'Mô Phỏng Đọc Thẻ NFC (Mock Test)',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Nút hành động tương ứng trạng thái
              if (_state == NfcSessionState.success && _currentMode == NfcMode.write) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('Hoàn Tất & Đóng'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ] else if (_state == NfcSessionState.success && _currentMode == NfcMode.read) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Đọc Thẻ Khác'),
                    onPressed: _startReadProcess,
                  ),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
