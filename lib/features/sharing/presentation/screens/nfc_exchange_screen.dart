import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/nfc_service.dart';
import '../../utils/qr_link_parser.dart';

class NfcExchangeScreen extends StatefulWidget {
  final String cardUrl;
  final String cardName;

  const NfcExchangeScreen({
    super.key,
    required this.cardUrl,
    required this.cardName,
  });

  @override
  State<NfcExchangeScreen> createState() => _NfcExchangeScreenState();
}

class _NfcExchangeScreenState extends State<NfcExchangeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
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

    _startNfcProcess();
  }

  @override
  void dispose() {
    _animController.dispose();
    NfcService.instance.stopSession();
    super.dispose();
  }

  Future<void> _startNfcProcess() async {
    final supported = await NfcService.instance.isNfcSupported();

    if (!supported) {
      if (mounted) {
        setState(() {
          _state = NfcSessionState.unsupported;
          _statusMessage = 'Thiết bị không hỗ trợ phần cứng NFC hoặc đang chạy trên máy ảo.\nBạn có thể nhấn nút "Mô phỏng NFC" bên dưới để kiểm thử tính năng.';
        });
      }
      return;
    }

    _writeToNfc();
  }

  void _writeToNfc() {
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

  void _runMockSimulation() {
    setState(() {
      _isMockMode = true;
      _state = NfcSessionState.waitingForTag;
    });

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
        return Icons.hourglass_top_rounded;
      default:
        return Icons.contactless_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi Thẻ Danh Thiếp NFC'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thông tin thẻ
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.credit_card_rounded,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.cardName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Animation Sóng NFC
              Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_state == NfcSessionState.waitingForTag ||
                          _state == NfcSessionState.writing)
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: List.generate(3, (index) {
                                final value =
                                    (_animController.value + index / 3.0) % 1.0;
                                return Container(
                                  width: 80 + value * 140,
                                  height: 80 + value * 140,
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
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor.withValues(alpha: 0.12),
                          border: Border.all(color: statusColor, width: 2),
                        ),
                        child: Icon(
                          _getStatusIcon(),
                          size: 48,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Trạng thái văn bản
              Text(
                _state == NfcSessionState.success
                    ? 'Ghi Thẻ Thành Công!'
                    : (_state == NfcSessionState.unsupported
                          ? 'Chưa Có Phần Cứng NFC'
                          : 'Sẵn Sàng Chạm Thẻ'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _statusMessage ?? 'Đặt mặt lưng điện thoại gần thẻ NFC trắng để ghi đường dẫn danh thiếp.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // URL được ghi
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.cardUrl,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2563EB),
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Nút thao tác
              if (_state == NfcSessionState.unsupported || _isMockMode) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _runMockSimulation,
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Mô Phỏng Chạm Thẻ NFC (Mock Test)'),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              if (_state == NfcSessionState.success) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Mở & Lưu Vào Ví (Chạm NFC)'),
                    onPressed: () {
                      final cardInfo = QrLinkParser.parse(widget.cardUrl);
                      if (cardInfo != null) {
                        Navigator.pop(context);
                        context.push(
                          '/public-card?ownerId=${cardInfo.ownerId}&cardId=${cardInfo.cardId}&source=nfc',
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hoàn Tất'),
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
