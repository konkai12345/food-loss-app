import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/inventory_service.dart';
import '../services/qr_code_service.dart';
import '../utils/error_handler.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  List<FoodItem> _inventoryItems = [];
  Map<String, dynamic> _analysis = {};
  List<Map<String, dynamic>> _warnings = [];
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = true;
  String _selectedTab = 'overview';

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }

  Future<void> _loadInventoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await InventoryService.getInventoryStatus();
      final analysis = await InventoryService.getInventoryAnalysis();
      final warnings = await InventoryService.getInventoryWarnings();
      final suggestions = await InventoryService.getInventoryOptimizationSuggestions();

      setState(() {
        _inventoryItems = items;
        _analysis = analysis;
        _warnings = warnings;
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'InventoryManagementScreen._loadInventoryData');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('在庫管理'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInventoryData,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _generateInventoryQRCode,
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
          _buildTabChip('warnings', '警告'),
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
      case 'warnings':
        return _buildWarningsTab();
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
          '在庫サマリー',
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
                '総アイテム数',
                '${_analysis['totalItems'] ?? 0}',
                Colors.blue,
                Icons.inventory,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '期限切れ',
                '${_analysis['expiredItems'] ?? 0}',
                Colors.red,
                Icons.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '期限近い',
                '${_analysis['soonExpiringItems'] ?? 0}',
                Colors.orange,
                Icons.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '新鮮',
                '${_analysis['freshItems'] ?? 0}',
                Colors.green,
                Icons.eco,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '消費済み',
                '${_analysis['consumedItems'] ?? 0}',
                Colors.grey,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '警告数',
                '${_warnings.length}',
                Colors.purple,
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

  Widget _buildAnalysisCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '在庫分析',
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
              child: _buildStorageChart(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChart() {
    final categoryData = _analysis['categoryAnalysis'] as Map<String, int>? ?? {};
    
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
            'カテゴリ別',
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
                    '${entry.value}件',
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

  Widget _buildStorageChart() {
    final storageData = _analysis['storageAnalysis'] as Map<String, int>? ?? {};
    
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
            '保管場所別',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...storageData.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStorageColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(entry.key),
                  ),
                  Text(
                    '${entry.value}件',
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
            '効率指標',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: InventoryService.calculateInventoryEfficiency(),
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

  Widget _buildWarningsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _warnings.length,
      itemBuilder: (context, index) {
        final warning = _warnings[index];
        return _buildWarningCard(warning);
      },
    );
  }

  Widget _buildWarningCard(Map<String, dynamic> warning) {
    final severity = warning['severity'] as String;
    final color = _getSeverityColor(severity);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            _getSeverityIcon(severity),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(warning['itemName']),
        subtitle: Text(warning['message']),
        trailing: Text(
          '${warning['daysUntilExpiry']}日',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        tileColor: color.withOpacity(0.05),
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
                '対象アイテム: ${suggestion['items']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _inventoryItems.length,
      itemBuilder: (context, index) {
        final item = _inventoryItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(FoodItem item) {
    final status = _getItemStatus(item);
    final statusColor = _getStatusColor(status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            _getStatusIcon(status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('期限: ${item.expiryDate.month}/${item.expiryDate.day}'),
            Text('保管場所: ${item.storageLocation}'),
            Text('カテゴリ: ${item.category}'),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.daysUntilExpiry}日',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item.price != null)
              Text(
                '¥${item.price}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        tileColor: statusColor.withOpacity(0.05),
      ),
    );
  }

  String _getItemStatus(FoodItem item) {
    if (item.isConsumed) return '消費済み';
    if (item.daysUntilExpiry < 0) return '期限切れ';
    if (item.daysUntilExpiry <= 3) return '期限近い';
    if (item.daysUntilExpiry <= 7) return '1週間以内';
    return '新鮮';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '消費済み':
        return Colors.grey;
      case '期限切れ':
        return Colors.red;
      case '期限近い':
        return Colors.orange;
      case '1週間以内':
        return Colors.yellow;
      case '新鮮':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case '消費済み':
        return Icons.check_circle;
      case '期限切れ':
        return Icons.error;
      case '期限近い':
        return Icons.warning;
      case '1週間以内':
        return Icons.schedule;
      case '新鮮':
        return Icons.eco;
      default:
        return Icons.help;
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

  Color _getStorageColor(String location) {
    final colors = {
      '冷蔵庫': Colors.blue,
      '冷凍庫': Colors.cyan,
      '常温': Colors.orange,
    };
    return colors[location] ?? Colors.grey;
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'high':
        return Icons.error;
      case 'medium':
        return Icons.warning;
      case 'low':
        return Icons.info;
      default:
        return Icons.help;
    }
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

  Future<void> _generateInventoryQRCode() async {
    try {
      final qrData = await InventoryService.generateInventoryQRCode();
      await QRCodeService.shareQRCode(qrData, title: '在庫管理QRコード');
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'InventoryManagementScreen._generateInventoryQRCode');
    }
  }
}
