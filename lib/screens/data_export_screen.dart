import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/data_export_service.dart';
import '../utils/error_handler.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await DataExportService.getDataStatistics();
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportScreen._loadStatistics');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('データエクスポート'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
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
                  // 統計情報
                  _buildStatisticsSection(),
                  const SizedBox(height: 20),
                  
                  // CSVエクスポート
                  _buildCSVExportSection(),
                  const SizedBox(height: 20),
                  
                  // JSONエクスポート
                  _buildJSONExportSection(),
                  const SizedBox(height: 20),
                  
                  // バックアップ・復元
                  _buildBackupSection(),
                  const SizedBox(height: 20),
                  
                  // データ管理
                  _buildDataManagementSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsSection() {
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
            'データ統計',
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
                  '食材',
                  '${_statistics['food_items']?['total'] ?? 0}',
                  Colors.blue,
                  Icons.inventory,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '買い物リスト',
                  '${_statistics['shopping_lists']?['total'] ?? 0}',
                  Colors.green,
                  Icons.shopping_cart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'レシピ',
                  '${_statistics['recipes']?['total'] ?? 0}',
                  Colors.orange,
                  Icons.restaurant_menu,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'ユーザー',
                  '${_statistics['users']?['total'] ?? 0}',
                  Colors.purple,
                  Icons.people,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'ファミリー',
                  '${_statistics['families']?['total'] ?? 0}',
                  Colors.red,
                  Icons.family_restroom,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '合計アイテム',
                  '${(_statistics['food_items']?['total'] ?? 0) + (_statistics['shopping_lists']?['total_items'] ?? 0)}',
                  Colors.grey,
                  Icons.summarize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCSVExportSection() {
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
            'CSVエクスポート',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildExportButton('food_items', '食材データ', Colors.blue),
              _buildExportButton('shopping_lists', '買い物リスト', Colors.green),
              _buildExportButton('recipes', 'レシピ', Colors.orange),
              _buildExportButton('users', 'ユーザー', Colors.purple),
              _buildExportButton('families', 'ファミリー', Colors.red),
              _buildExportButton('all', 'すべてのデータ', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJSONExportSection() {
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
            'JSONエクスポート',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildJSONExportButton('food_items', '食材データ', Colors.blue),
              _buildJSONExportButton('shopping_lists', '買い物リスト', Colors.green),
              _buildJSONExportButton('recipes', 'レシピ', Colors.orange),
              _buildJSONExportButton('users', 'ユーザー', Colors.purple),
              _buildJSONExportButton('families', 'ファミリー', Colors.red),
              _buildJSONExportButton('all', 'すべてのデータ', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSection() {
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
            'バックアップ・復元',
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
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _createBackup,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.backup),
                  label: Text(_isExporting ? '作成中...' : 'バックアップ作成'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _restoreBackup,
                  icon: const Icon(Icons.restore),
                  label: const Text('復元'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
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
            'データ管理',
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
                child: ElevatedButton.icon(
                  onPressed: _cleanupOldData,
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text('古いデータを削除'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareAllData,
                  icon: const Icon(Icons.share),
                  label: const Text('すべて共有'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(String dataType, String label, Color color) {
    return ElevatedButton.icon(
      onPressed: _isExporting ? null : () => _exportToCSV(dataType),
      icon: const Icon(Icons.file_download),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildJSONExportButton(String dataType, String label, Color color) {
    return ElevatedButton.icon(
      onPressed: _isExporting ? null : () => _exportToJSON(dataType),
      icon: const Icon(Icons.code),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _exportToCSV(String dataType) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final filePath = await DataExportService.exportToCSV(dataType);
      await DataExportService.shareData(filePath);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$dataType のCSVエクスポートが完了しました'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportScreen._exportToCSV');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSVエクスポートに失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportToJSON(String dataType) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final filePath = await DataExportService.exportToJSON(dataType);
      await DataExportService.shareData(filePath);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$dataType のJSONエクスポートが完了しました'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportScreen._exportToJSON');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('JSONエクスポートに失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _createBackup() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final filePath = await DataExportService.createBackup();
      await DataExportService.shareData(filePath);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('バックアップが完了しました'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportScreen._createBackup');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('バックアップに失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _restoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final success = await DataExportService.restoreFromBackup(filePath);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('データの復元が完了しました'),
              duration: const Duration(seconds: 2),
            ),
          );
          _loadStatistics(); // 統計情報を再読み込み
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('データの復元に失敗しました'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportScreen._restoreBackup');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('データの復元に失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cleanupOldData() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('古いデータの削除'),
          content: const Text('1年以上前のデータを削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await DataExportService.cleanupOldData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('古いデータを削除しました'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                _loadStatistics();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareAllData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final filePath = await DataExportService.exportToJSON('all');
      await DataExportService.shareData(filePath);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('すべてのデータを共有しました'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportScreen._shareAllData');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('データの共有に失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }
}
