import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/purchase_service.dart';
import '../services/qr_code_service.dart';
import '../utils/error_handler.dart';

class PurchaseManagementScreen extends StatefulWidget {
  const PurchaseManagementScreen({super.key});

  @override
  State<PurchaseManagementScreen> createState() => _PurchaseManagementScreenState();
}

class _PurchaseManagementScreenState extends State<PurchaseManagementScreen> {
  List<FoodItem> _purchaseItems = [];
  Map<String, dynamic> _analysis = {};
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = true;
  String _selectedTab = 'overview';

  @override
  void initState() {
    super.initState();
    _loadPurchaseData();
  }

  Future<void> _loadPurchaseData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await PurchaseService.getPurchaseData();
      final analysis = await PurchaseService.getPurchaseAnalysis();
      final suggestions = await PurchaseService.getPurchaseOptimizationSuggestions();

      setState(() {
        _purchaseItems = items.where((item) => item.price != null && item.price! > 0).toList();
        _analysis = analysis;
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'PurchaseManagementScreen._loadPurchaseData');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('購入管理'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPurchaseData,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _generatePurchaseQRCode,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // タブ選択
                _buildTabSelector(),
                const SizedBox(height: 16),
                
                // タブコンテンツ
                Expanded(
                  child: _buildTabContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildTabChip('overview', '概要'),
          _buildTabChip('trends', 'トレンド'),
          _buildTabChip('suggestions', '提案'),
          _buildTabChip('items', 'アイテム'),
        ],
      ),
    );
  }

  Widget _buildTabChip(String tab, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _selectedTab == tab,
        onSelected: (selected) {
          setState(() {
            _selectedTab = tab;
          });
        },
        backgroundColor: _selectedTab == tab ? Colors.green : Colors.grey[200],
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: _selectedTab == tab ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'overview':
        return _buildOverviewTab();
      case 'trends':
        return _buildTrendsTab();
      case 'suggestions':
        return _buildSuggestionsTab();
      case 'items':
        return _buildItemsTab();
      default:
        return const Center(child: Text('不明なタブ'));
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 統計サマリー
          _buildSummaryCards(),
          const SizedBox(height: 20),
          
          // 分析グラフ
          _buildAnalysisCharts(),
          const SizedBox(height: 20),
          
          // 効率指標
          _buildEfficiencyMetrics(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '購入サマリー',
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
                '総購入数',
                '${_analysis['totalItems'] ?? 0}',
                Colors.blue,
                Icons.shopping_cart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '総金額',
                '¥${(_analysis['totalAmount'] ?? 0).toStringAsFixed(0)}',
                Colors.green,
                Icons.attach_money,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '平均価格',
                '¥${(_analysis['averagePrice'] ?? 0).toStringAsFixed(0)}',
                Colors.orange,
                Icons.price_check,
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

  Widget _buildAnalysisCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '購入分析',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCategoryChart(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStoreChart(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChart() {
    final categoryData = _analysis['categoryPurchases'] as Map<String, double>? ?? {};
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'カテゴリ別購入',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...categoryData.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(entry.key),
                  ),
                  Text(
                    '¥${entry.value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStoreChart() {
    final storeData = _analysis['storePurchases'] as Map<String, double>? ?? {};
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '店舗別購入',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...storeData.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStoreColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(entry.key),
                  ),
                  Text(
                    '¥${entry.value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEfficiencyMetrics() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '購入効率',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: PurchaseService.calculatePurchaseEfficiency(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final efficiency = snapshot.data!;
              return Column(
                children: [
                  _buildEfficiencyItem('消費率', '${efficiency['consumptionRate']?.toStringAsFixed(1)}%', Colors.green),
                  _buildEfficiencyItem('ロス率', '${efficiency['wasteRate']?.toStringAsFixed(1)}%', Colors.red),
                  _buildEfficiencyItem('効率スコア', '${efficiency['efficiencyScore']?.toStringAsFixed(1)}', Colors.blue),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyItem(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // トレンド分析
          _buildTrendAnalysis(),
          const SizedBox(height: 20),
          
          // 月次推移
          _buildMonthlyTrends(),
          const SizedBox(height: 20),
          
          // 予測
          _buildForecast(),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    return Container(
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
      child: FutureBuilder(
        future: PurchaseService.analyzePurchaseTrends(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final trends = snapshot.data!;
          final trend = trends['trend'] as String;
          final growthRate = trends['growthRate'] as double;
          final recommendation = trends['recommendation'] as String;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'トレンド分析',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getTrendColor(trend),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTrendLabel(trend),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '成長率',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${growthRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getTrendColor(trend),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _getRecommendationText(recommendation),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthlyTrends() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '月次推移',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: PurchaseService.generatePurchaseReport(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final report = snapshot.data!;
              final monthlyHistory = report['monthlyHistory'] as List<Map<String, dynamic>>;
              
              return Column(
                children: monthlyHistory.map((monthData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            monthData['month'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '¥${monthData['totalAmount'].toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '(${monthData['itemCount']}件)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForecast() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '購入予測',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: PurchaseService.calculatePurchaseForecast(6),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final forecast = snapshot.data!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '6ヶ月予測',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '予測金額: ¥${forecast['forecastAmount']?.toStringAsFixed(0) ?? '0'}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '月平均: ¥${forecast['averageMonthlyAmount']?.toStringAsFixed(0) ?? '0'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: forecast['confidence'] as double,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '信頼度: ${((forecast['confidence'] as double? ?? 0.0) * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return _buildSuggestionCard(suggestion);
      },
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    final priority = suggestion['priority'] as String;
    final color = _getPriorityColor(priority);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              suggestion['description'],
              style: const TextStyle(fontSize: 14),
            ),
            if (suggestion['items'] != null) ...[
              const SizedBox(height: 8),
              Text(
                '対象: ${suggestion['items']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _handleSuggestionAction(suggestion);
                    },
                    child: const Text('対応する'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _dismissSuggestion(int index) {};
                    },
                    child: const Text('無視する'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _purchaseItems.length,
      itemBuilder: (context, index) {
        final item = _purchaseItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(FoodItem item) {
    final daysUntilExpiry = item.daysUntilExpiry;
    final statusColor = _getDaysUntilExpiryColor(daysUntilExpiry);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            _getDaysUntilExpiryIcon(daysUntilExpiry),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('購入日: ${item.registrationDate.month}/${item.registrationDate.day}'),
            Text('期限: ${item.expiryDate.month}/${item.expiryDate.day}'),
            Text('保管場所: ${item.storageLocation}'),
            Text('カテゴリ: ${item.category}'),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '¥${item.price}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              '${item.quantity}個',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        tileColor: statusColor.withOpacity(0.05),
      ),
    );
  }

  String _getTrendLabel(String trend) {
    switch (trend) {
      case 'increasing':
        return '増加傾向';
      case 'decreasing':
        return '減少傾向';
      case 'stable':
        return '安定';
      default:
        return '不明';
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'increasing':
        return Colors.green;
      case 'decreasing':
        return Colors.red;
      case 'stable':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getRecommendationText(String recommendation) {
    switch (recommendation) {
      case 'budget_increase':
        return '予算の増加を検討してください';
      case 'budget_decrease':
        return '予算の削減を検討してください';
      case 'maintain_budget':
        return '現在の予算を維持してください';
      default:
        return 'データが不足しています';
    }
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

  Color _getStoreColor(String store) {
    final colors = {
      'スーパー': Colors.blue,
      'コンビニ': Colors.green,
      'ドラッグストア': Colors.orange,
    };
    return colors[store] ?? Colors.grey;
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getDaysUntilExpiryColor(int days) {
    if (days < 0) return Colors.red;
    if (days <= 3) return Colors.orange;
    if (days <= 7) return Colors.yellow;
    return Colors.green;
  }

  IconData _getDaysUntilExpiryIcon(int days) {
    if (days < 0) return Icons.error;
    if (days <= 3) return Icons.warning;
    if (days <= 7) return Icons.schedule;
    return Icons.eco;
  }

  Future<void> _generatePurchaseQRCode() async {
    try {
      final qrData = await PurchaseService.generatePurchaseQRCode();
      await QRCodeService.shareQRCode(qrData, title: '購入管理QRコード');
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'PurchaseManagementScreen._generatePurchaseQRCode');
    }
  }

  void _handleSuggestionAction(Map<String, dynamic> suggestion) {
    // 提案に基づいてアクションを実装
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${suggestion['title']}の対応を開始します'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _dismissSuggestion(int index) {
    setState(() {
      _suggestions.removeAt(index);
    });
  }
}
