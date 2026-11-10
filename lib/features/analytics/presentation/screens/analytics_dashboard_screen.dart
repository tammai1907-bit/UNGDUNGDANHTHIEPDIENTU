import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:digital_business_card/features/card_design/presentation/providers/card_list_controller.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_repository_provider.dart'
    show useMockDataProvider;
import 'package:digital_business_card/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:digital_business_card/features/analytics/domain/entities/card_analytics.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  int _selectedChartMetric =
      0; // 0: Tổng tương tác, 1: Lượt xem, 2: Quét QR, 3: Chạm NFC

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(myCardsStreamProvider);
    final analyticsAsync = ref.watch(cardAnalyticsStreamProvider);
    final selectedCardId = ref.watch(selectedAnalyticsCardIdProvider);
    final useMockData = ref.watch(useMockDataProvider);
    final analyticsRepo = ref.watch(analyticsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống Kê Tương Tác'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới số liệu',
            onPressed: () {
              ref.invalidate(cardAnalyticsStreamProvider);
            },
          ),
        ],
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Chưa có danh thiếp nào để xem dữ liệu thống kê.'),
              ),
            );
          }

          final currentCard = cards.firstWhere(
            (c) => c.id == selectedCardId,
            orElse: () =>
                cards.firstWhere((c) => c.isDefault, orElse: () => cards.first),
          );

          return analyticsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Center(child: Text('Lỗi tải thống kê: $err')),
            data: (analytics) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bộ chọn danh thiếp đa hồ sơ (Multi-profile)
                    if (cards.length > 1) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currentCard.id,
                            isExpanded: true,
                            items: cards.map((c) {
                              return DropdownMenuItem<String>(
                                value: c.id,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.credit_card,
                                      size: 18,
                                      color: Color(0xFF2563EB),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${c.cardName} (${c.fullName})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newId) {
                              if (newId != null) {
                                ref
                                        .read(
                                          selectedAnalyticsCardIdProvider
                                              .notifier,
                                        )
                                        .state =
                                    newId;
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 4 Thẻ KPI Tóm Tắt Tương Tác
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            context: context,
                            title: 'Lượt Xem Thẻ',
                            value: analytics.totalViews.toString(),
                            subtitle: 'Tổng lượt xem',
                            icon: Icons.visibility_outlined,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildKpiCard(
                            context: context,
                            title: 'Quét Mã QR',
                            value: analytics.totalQrScans.toString(),
                            subtitle: 'Ghi nhận qua QR',
                            icon: Icons.qr_code_2_rounded,
                            color: const Color(0xFF7C3AED),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            context: context,
                            title: 'Chạm Thẻ NFC',
                            value: analytics.totalNfcTaps.toString(),
                            subtitle: 'Ghi nhận qua NFC',
                            icon: Icons.nfc_rounded,
                            color: const Color(0xFFEA580C),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildKpiCard(
                            context: context,
                            title: 'Lưu Danh Bạ',
                            value: analytics.totalSaves.toString(),
                            subtitle: 'Đã lưu từ danh thiếp',
                            icon: Icons.bookmark_added_outlined,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Biểu đồ tương tác 7 ngày gần nhất (fl_chart BarChart)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Biểu đồ tương tác 7 ngày qua',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Thống kê theo lượt xem, QR & NFC',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.bar_chart_rounded,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Bộ lọc dữ liệu hiển thị trên cột
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('Tất cả', 0),
                                const SizedBox(width: 6),
                                _buildFilterChip('Lượt xem', 1),
                                const SizedBox(width: 6),
                                _buildFilterChip('Quét QR', 2),
                                const SizedBox(width: 6),
                                _buildFilterChip('Chạm NFC', 3),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Khung biểu đồ BarChart
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _calculateMaxY(analytics.dailyStats),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                          final day = analytics
                                              .dailyStats[group.x.toInt()];
                                          final dateStr = DateFormat('dd/MM')
                                              .format(day.date);
                                          return BarTooltipItem(
                                            '$dateStr\n',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '👁️ Xem: ${day.views}\n📱 QR: ${day.qrScans}\n⚡ NFC: ${day.nfcTaps}\n📥 Lưu: ${day.saves}',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 11,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index >= 0 &&
                                            index <
                                                analytics.dailyStats.length) {
                                          final date =
                                              analytics.dailyStats[index].date;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Text(
                                              DateFormat('dd/MM').format(date),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.grey.withValues(alpha: 0.15),
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(
                                  analytics.dailyStats.length,
                                  (i) {
                                    final day = analytics.dailyStats[i];
                                    final value = _getMetricValue(day);
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: value.toDouble(),
                                          color: _getMetricColor(),
                                          width: 14,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(6),
                                              ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getMetricColor(),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Dữ liệu hiển thị: ${_getMetricName()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Phân bổ lượt nhấp theo từng liên kết
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Phân bổ lượt nhấp liên kết',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Tỷ trọng trên tổng lượt nhấp',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16A34A)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.touch_app_rounded,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (analytics.linkClicks.isEmpty)
                            const Text(
                              'Chưa có lượt nhấp liên kết nào.',
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            ...analytics.linkClicks.map((item) {
                              final brandColor = _getColorForLinkType(
                                item.type,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              _getIconForLinkType(item.type),
                                              size: 16,
                                              color: brandColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              item.label,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${item.clicks} lượt (${item.percentage.toStringAsFixed(1)}%)',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: (item.percentage / 100.0).clamp(
                                          0.0,
                                          1.0,
                                        ),
                                        minHeight: 8,
                                        backgroundColor: Colors.grey.withValues(
                                          alpha: 0.15,
                                        ),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              brandColor,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (useMockData) ...[
                      // Panel kiểm thử chỉ ghi dữ liệu vào kho giả lập.
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB)
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2563EB)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.flash_on_rounded,
                                  color: Color(0xFF2563EB),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Kiểm Thử Tương Tác Thời Gian Thực',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Nhấn vào các nút bên dưới để mô phỏng sự kiện từ đối tác và quan sát biểu đồ cập nhật trực tiếp:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('+1 Lượt xem'),
                                  onPressed: () {
                                    analyticsRepo.recordEvent(
                                      cardId: currentCard.id,
                                      eventType: 'view',
                                    );
                                  },
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7C3AED),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.qr_code_2, size: 16),
                                  label: const Text('+1 Quét QR'),
                                  onPressed: () {
                                    analyticsRepo.recordEvent(
                                      cardId: currentCard.id,
                                      eventType: 'qr_scan',
                                    );
                                  },
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEA580C),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.nfc, size: 16),
                                  label: const Text('+1 Chạm NFC'),
                                  onPressed: () {
                                    analyticsRepo.recordEvent(
                                      cardId: currentCard.id,
                                      eventType: 'nfc_tap',
                                    );
                                  },
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.bookmark_added_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('+1 Lưu danh bạ'),
                                  onPressed: () {
                                    analyticsRepo.recordEvent(
                                      cardId: currentCard.id,
                                      eventType: 'save',
                                    );
                                  },
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.touch_app, size: 16),
                                  label: const Text('+1 Click LinkedIn'),
                                  onPressed: () {
                                    analyticsRepo.recordEvent(
                                      cardId: currentCard.id,
                                      eventType: 'link_click',
                                      linkType: 'linkedin',
                                    );
                                  },
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.phone, size: 16),
                                  label: const Text('+1 Click Gọi'),
                                  onPressed: () {
                                    analyticsRepo.recordEvent(
                                      cardId: currentCard.id,
                                      eventType: 'link_click',
                                      linkType: 'phone',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 36),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedChartMetric == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedChartMetric = index);
      },
    );
  }

  int _getMetricValue(DailyInteraction day) {
    switch (_selectedChartMetric) {
      case 1:
        return day.views;
      case 2:
        return day.qrScans;
      case 3:
        return day.nfcTaps;
      default:
        return day.total;
    }
  }

  Color _getMetricColor() {
    switch (_selectedChartMetric) {
      case 1:
        return const Color(0xFF2563EB); // Views
      case 2:
        return const Color(0xFF7C3AED); // QR
      case 3:
        return const Color(0xFFEA580C); // NFC
      default:
        return const Color(0xFF2563EB); // Total
    }
  }

  String _getMetricName() {
    switch (_selectedChartMetric) {
      case 1:
        return 'Lượt xem trực tiếp';
      case 2:
        return 'Quét mã QR';
      case 3:
        return 'Chạm thẻ NFC';
      default:
        return 'Tổng số tương tác (Xem + QR + NFC + Lưu)';
    }
  }

  double _calculateMaxY(List<DailyInteraction> stats) {
    if (stats.isEmpty) return 30;
    int maxVal = 0;
    for (final s in stats) {
      final v = _getMetricValue(s);
      if (v > maxVal) maxVal = v;
    }
    return ((maxVal ~/ 10) + 1) * 10.0 + 5.0;
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Icon(Icons.trending_up, size: 16, color: Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLinkType(String type) {
    switch (type) {
      case 'linkedin':
        return Icons.link;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'website':
        return Icons.language;
      case 'github':
        return Icons.code;
      case 'facebook':
        return Icons.facebook;
      default:
        return Icons.touch_app;
    }
  }

  Color _getColorForLinkType(String type) {
    switch (type) {
      case 'linkedin':
        return const Color(0xFF0077B5);
      case 'phone':
        return const Color(0xFF16A34A);
      case 'zalo':
        return const Color(0xFF0068FF);
      case 'github':
        return const Color(0xFF24292E);
      case 'email':
        return const Color(0xFFEA4335);
      case 'website':
        return const Color(0xFF6366F1);
      case 'facebook':
        return const Color(0xFF1877F2);
      default:
        return const Color(0xFF2563EB);
    }
  }
}
