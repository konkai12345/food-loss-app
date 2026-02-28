import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';
import '../utils/error_handler.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic> _analyticsData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await AnalyticsService.getAnalyticsSummary();
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'AnalyticsScreen._loadAnalyticsData');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('データ分析'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 統計サマリー
                  _buildSummaryCards(),
                  const SizedBox(height: 20),
                  
                  // グラフセクション
                  _buildChartsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        const Text(
          'ロス削減サマリー',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '総ロス量',
                '¥${(_analyticsData['totalWasted'] ?? 0).toStringAsFixed(0)}',
                Colors.red,
                Icons.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '削減効果',
                '¥${(_analyticsData['totalReduction'] ?? 0).toStringAsFixed(0)}',
                Colors.green,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '削減率',
                '${(_analyticsData['reductionRate'] ?? 0).toStringAsFixed(1)}%',
                Colors.blue,
                Icons.percent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '総アイテム数',
                '${_analyticsData['totalItems'] ?? 0}',
                Colors.grey,
                Icons.inventory,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '期限切れ',
                '${_analyticsData['expiredCount'] ?? 0}',
                Colors.orange,
                Icons.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '期限近い',
                '${_analyticsData['soonCount'] ?? 0}',
                Colors.amber,
                Icons.warning_amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '詳細分析',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // 月次推移グラフ
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildMonthlyTrendChart(),
        ),
        const SizedBox(height: 20),
        
        // カテゴリ別分析
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildCategoryChart(),
        ),
        const SizedBox(height: 20),
        
        // 保管場所別分析
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildStorageChart(),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrendChart() {
    final monthlyData = _analyticsData['monthlyData'] as Map<String, List<dynamic>>? ?? {};
    
    if (monthlyData.isEmpty) {
      return const Center(
        child: Text('データがありません'),
      );
    }

    final months = monthlyData.keys.toList()..sort();
    final wastedData = months.map((month) => monthlyData[month]![0] as double).toList();
    final consumedData = months.map((month) => monthlyData[month]![1] as double).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '月次ロス削減推移',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              lineBarsData: [
                // ロス量
                LineChartBarData(
                  spots: List.generate(months.length, (i) => 
                    FlSpot(i.toDouble(), wastedData[i])),
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.red.withOpacity(0.2),
                  ),
                ),
                // 削減効果
                LineChartBarData(
                  spots: List.generate(months.length, (i) => 
                    FlSpot(i.toDouble(), consumedData[i])),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.withOpacity(0.2),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final style = TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      );
                      if (value.toInt() < months.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            months[value.toInt()],
                            style: style,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1000,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final style = TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      );
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '¥${value.toInt()}',
                          style: style,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart() {
    final categoryData = _analyticsData['categoryWaste'] as Map<String, double>? ?? {};
    
    if (categoryData.isEmpty) {
      return const Center(
        child: Text('データがありません'),
      );
    }

    final categories = categoryData.keys.toList();
    final values = categoryData.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'カテゴリ別ロス分析',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: PieChart(
            PieChartData(
              sections: List.generate(categories.length, (i) {
                return PieChartSectionData(
                  value: values[i],
                  title: '${categories[i]} (${values[i].toStringAsFixed(0)}円)',
                  color: _getCategoryColor(categories[i]),
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStorageChart() {
    final storageData = _analyticsData['storageWaste'] as Map<String, double>? ?? {};
    
    if (storageData.isEmpty) {
      return const Center(
        child: Text('データがありません'),
      );
    }

    final locations = storageData.keys.toList();
    final values = storageData.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '保管場所別ロス分析',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              barGroups: List.generate(locations.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: values[i],
                      color: _getStorageColor(locations[i]),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                        bottom: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final style = TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      );
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          locations[value.toInt()],
                          style: style,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 500,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final style = TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      );
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '¥${value.toInt()}',
                          style: style,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      '野菜': Colors.green,
      '果物': Colors.orange,
      '肉': Colors.red,
      '魚': Colors.blue,
      '乳製品': Colors.purple,
      '調味料': Colors.brown,
      'その他': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }

  Color _getStorageColor(String location) {
    final colors = {
      '冷蔵庫': Colors.blue,
      '冷凍庫': Colors.cyan,
      '常温': Colors.orange,
    };
    return colors[location] ?? Colors.grey;
  }
}
