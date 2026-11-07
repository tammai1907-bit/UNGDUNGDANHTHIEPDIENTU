import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/card_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context);
    final activeCard = cardProvider.activeCard;
    final analytics = cardProvider.activeAnalytics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống Kê & Phân Tích (Analytics)'),
      ),
      body: activeCard == null || analytics == null
          ? const Center(child: Text('Chưa có dữ liệu thống kê.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown chọn thẻ để xem thống kê
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: activeCard.id,
                        isExpanded: true,
                        items: cardProvider.myCards.map((c) {
                          return DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              '📊 ${c.cardName} (${c.fullName})',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id != null) {
                            final selected = cardProvider.myCards.firstWhere((c) => c.id == id);
                            cardProvider.setActiveCard(selected);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Overview Metric Cards Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Tổng Lượt Xem',
                          value: '${analytics.totalViews}',
                          icon: Icons.visibility,
                          color: const Color(0xFF2563EB),
                          growth: '+18% tuần này',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Lưu Danh Bạ',
                          value: '${analytics.totalSaves}',
                          icon: Icons.bookmark_added,
                          color: const Color(0xFF16A34A),
                          growth: '+12% tuần này',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Quét Mã QR',
                          value: '${analytics.qrScans}',
                          icon: Icons.qr_code_2,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Chạm Thẻ NFC',
                          value: '${analytics.nfcTaps}',
                          icon: Icons.nfc,
                          color: const Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Biểu đồ lượt xem theo ngày (fl_chart BarChart)
                  const Text(
                    'Lượt Xem Danh Thiếp 7 Ngày Gần Nhất',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 220,
                    padding: const EdgeInsets.only(top: 24, right: 16, left: 8, bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 40,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                                int index = val.toInt();
                                if (index >= 0 && index < days.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(days[index], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _buildBarGroup(0, 14, const Color(0xFF3B82F6)),
                          _buildBarGroup(1, 21, const Color(0xFF3B82F6)),
                          _buildBarGroup(2, 18, const Color(0xFF3B82F6)),
                          _buildBarGroup(3, 29, const Color(0xFF3B82F6)),
                          _buildBarGroup(4, 25, const Color(0xFF3B82F6)),
                          _buildBarGroup(5, 35, const Color(0xFF2563EB)),
                          _buildBarGroup(6, 19, const Color(0xFF3B82F6)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tỷ Lệ Nhấp (Click-Through Rate) vào Mạng Xã Hội / Liên kết
                  const Text(
                    'Tỷ Lệ Nhấp Vào Các Kênh (Click-Through Rate)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildClickProgressRow('LinkedIn Profile', 45, 100, const Color(0xFF0A66C2)),
                        const Divider(height: 20),
                        _buildClickProgressRow('Website / Portfolio', 32, 100, const Color(0xFF2563EB)),
                        const Divider(height: 20),
                        _buildClickProgressRow('Gọi Điện Thoại Trực Tiếp', 24, 100, const Color(0xFF16A34A)),
                        const Divider(height: 20),
                        _buildClickProgressRow('Gửi Email Hợp Tác', 18, 100, const Color(0xFFE11D48)),
                        const Divider(height: 20),
                        _buildClickProgressRow('GitHub Repository', 20, 100, const Color(0xFF18181B)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? growth,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          if (growth != null) ...[
            const SizedBox(height: 4),
            Text(growth, style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  Widget _buildClickProgressRow(String label, int clicks, int maxClicks, Color color) {
    final percent = (clicks / maxClicks).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
            Text('$clicks lượt nhấp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
