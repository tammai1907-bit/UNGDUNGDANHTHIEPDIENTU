import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:digital_business_card/features/card_design/presentation/providers/card_list_controller.dart';
import 'package:digital_business_card/features/analytics/presentation/providers/analytics_providers.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(myCardsStreamProvider);
    final analyticsAsync = ref.watch(cardAnalyticsFutureProvider);
    final selectedCardId = ref.watch(selectedAnalyticsCardIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống Kê Tương Tác'),
        centerTitle: true,
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(
              child: Text('Chưa có danh thiếp nào để xem dữ liệu thống kê.'),
            );
          }

          final currentCard = cards.firstWhere(
            (c) => c.id == selectedCardId,
            orElse: () => cards.firstWhere((c) => c.isDefault, orElse: () => cards.first),
          );

          return RefreshIndicator(
            onRefresh: () => ref.refresh(cardAnalyticsFutureProvider.future),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bộ chọn danh thiếp
                  if (cards.length > 1) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentCard.id,
                          isExpanded: true,
                          items: cards.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(
                                '${c.cardName} (${c.fullName})',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                          onChanged: (newId) {
                            if (newId != null) {
                              ref.read(selectedAnalyticsCardIdProvider.notifier).state = newId;
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  analyticsAsync.when(
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    )),
                    error: (err, _) => Center(child: Text('Lỗi tải thống kê: $err')),
                    data: (analytics) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 4 thẻ tóm tắt KPI
                          Row(
                            children: [
                              Expanded(
                                child: _buildKpiCard(
                                  context: context,
                                  title: 'Lượt Xem Thẻ',
                                  value: analytics.totalViews.toString(),
                                  icon: Icons.visibility_outlined,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildKpiCard(
                                  context: context,
                                  title: 'Lưu Danh Bạ',
                                  value: analytics.totalSaves.toString(),
                                  icon: Icons.bookmark_added_outlined,
                                  color: const Color(0xFF16A34A),
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
                                  title: 'Quét Mã QR',
                                  value: analytics.totalQrScans.toString(),
                                  icon: Icons.qr_code_2_rounded,
                                  color: const Color(0xFF7C3AED),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildKpiCard(
                                  context: context,
                                  title: 'Chạm Thẻ NFC',
                                  value: analytics.totalNfcTaps.toString(),
                                  icon: Icons.nfc_rounded,
                                  color: const Color(0xFFEA580C),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Biểu đồ tương tác 7 ngày gần nhất
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
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tương tác trong tuần qua',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Icon(Icons.bar_chart, color: Color(0xFF2563EB)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 180,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: 45,
                                      barTouchData: BarTouchData(enabled: true),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              final index = value.toInt();
                                              if (index >= 0 && index < analytics.dailyStats.length) {
                                                final date = analytics.dailyStats[index].date;
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 6),
                                                  child: Text(
                                                    DateFormat('dd/MM').format(date),
                                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                        leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                      ),
                                      gridData: const FlGridData(show: false),
                                      borderData: FlBorderData(show: false),
                                      barGroups: List.generate(analytics.dailyStats.length, (i) {
                                        final day = analytics.dailyStats[i];
                                        return BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: day.total.toDouble(),
                                              color: const Color(0xFF2563EB),
                                              width: 14,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Tỷ lệ nhấp vào các liên kết mạng xã hội (CTR)
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
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tỷ lệ nhấp liên kết (CTR)',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Icon(Icons.touch_app_outlined, color: Color(0xFF16A34A)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...analytics.linkClicks.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                            Text('${item.clicks} lượt (${item.percentage.toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: LinearProgressIndicator(
                                            value: item.percentage / 100.0,
                                            minHeight: 8,
                                            backgroundColor: Colors.grey.withValues(alpha: 0.15),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              _getColorForLinkType(item.type),
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

                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required String value,
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
              const Icon(Icons.arrow_upward, size: 14, color: Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 14),
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
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
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
      default:
        return const Color(0xFF2563EB);
    }
  }
}
