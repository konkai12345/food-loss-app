import 'package:flutter/material.dart';
import '../models/waste_separation.dart';
import '../services/waste_separation_service.dart';
import '../utils/error_handler.dart';

class WasteSeparationScreen extends StatefulWidget {
  const WasteSeparationScreen({super.key});

  @override
  State<WasteSeparationScreen> createState() => _WasteSeparationScreenState();
}

class _WasteSeparationScreenState extends State<WasteSeparationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<WasteSeparationResult> _searchResults = [];
  List<WasteSeparationHistory> _history = [];
  List<RegionSettings> _regions = [];
  RegionSettings? _selectedRegion;
  bool _isLoading = false;
  bool _isSearching = false;
  String _selectedTab = 'search';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final regions = await WasteSeparationService.getRegionSettings();
      final history = await WasteSeparationService.getHistory();
      
      setState(() {
        _regions = regions;
        _selectedRegion = regions.isNotEmpty ? regions.first : null;
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WasteSeparationScreen._loadData');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ゴミ分別'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 地域選択
                _buildRegionSelector(),
                const SizedBox(height: 16),
                
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

  Widget _buildRegionSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<RegionSettings>(
        value: _selectedRegion,
        decoration: const InputDecoration(
          labelText: '地域を選択',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.location_on),
        ),
        items: _regions.map((region) {
          return DropdownMenuItem(
            value: region,
            child: Text(region.name),
          );
        }).toList(),
        onChanged: (region) {
          setState(() {
            _selectedRegion = region;
          });
          _loadHistory();
        },
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
          _buildTabChip('search', '検索'),
          _buildTabChip('calendar', 'カレンダー'),
          _buildTabChip('categories', 'カテゴリ'),
          _buildTabChip('history', '履歴'),
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
      case 'search':
        return _buildSearchTab();
      case 'calendar':
        return _buildCalendarTab();
      case 'categories':
        return _buildCategoriesTab();
      case 'history':
        return _buildHistoryTab();
      default:
        return const Center(child: Text('不明なタブ'));
    }
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // 検索バー
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'ゴミの名前を入力',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults.clear();
                  });
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _searchWasteSeparation(value);
              }
            },
          ),
        ),
        
        // 検索結果
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? const Center(child: Text('検索結果がありません'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return _buildSearchResultCard(result);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSearchResultCard(WasteSeparationResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: result.category.color,
          child: Icon(
            result.category.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(result.itemName),
        subtitle: Text(result.category.displayName),
        trailing: Text('${(result.confidence * 100).toStringAsFixed(0)}%'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.description != null) ...[
                  Text(
                    '説明',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(result.description!),
                  const SizedBox(height: 12),
                ],
                
                Text(
                  '収集日',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                ...result.collectionDays.map((day) => Text('• $day')),
                const SizedBox(height: 12),
                
                if (result.notes.isNotEmpty) ...[
                  Text(
                    '注意事項',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...result.notes.map((note) => Text('• $note')),
                  const SizedBox(height: 12),
                ],
                
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _addToHistory(result),
                      icon: const Icon(Icons.check),
                      label: const Text('正しい'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _reportIncorrect(result),
                      icon: const Icon(Icons.close),
                      label: const Text('間違い'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    if (_selectedRegion == null) {
      return const Center(child: Text('地域を選択してください'));
    }

    return FutureBuilder<Map<String, List<String>>>(
      future: WasteSeparationService.getWasteCalendar(_selectedRegion!.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final calendar = snapshot.data!;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: calendar.length,
          itemBuilder: (context, index) {
            final day = calendar.keys.elementAt(index);
            final categories = calendar[day]!;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    day.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(day),
                subtitle: Text(categories.join('、')),
                tileColor: Colors.blue.withOpacity(0.05),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: WasteCategory.values.length,
      itemBuilder: (context, index) {
        final category = WasteCategory.values[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(WasteCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: category.color,
          child: Icon(
            category.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(category.displayName),
        subtitle: Text(category.description),
        children: [
          FutureBuilder<List<WasteSeparationRule>>(
            future: WasteSeparationService.getRulesByCategory(category),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final rules = snapshot.data!;
              if (rules.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('このカテゴリのアイテムがありません'),
                );
              }

              return Column(
                children: rules.map((rule) {
                  return ListTile(
                    title: Text(rule.itemName),
                    subtitle: rule.description != null ? Text(rule.description!) : null,
                    onTap: () {
                      _searchController.text = rule.itemName;
                      _searchWasteSeparation(rule.itemName);
                      setState(() {
                        _selectedTab = 'search';
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final history = _history[index];
        return _buildHistoryCard(history);
      },
    );
  }

  Widget _buildHistoryCard(WasteSeparationHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: history.category.color,
          child: Icon(
            history.category.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(history.itemName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(history.category.displayName),
            Text('${history.createdAt.month}/${history.createdAt.day} ${history.createdAt.hour}:${history.createdAt.minute.toString().padLeft(2, '0')}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              history.isCorrect ? Icons.check_circle : Icons.error,
              color: history.isCorrect ? Colors.green : Colors.red,
            ),
            if (history.region != null) ...[
              const SizedBox(width: 8),
              Text(
                history.region!,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        tileColor: history.isCorrect 
            ? Colors.green.withOpacity(0.05) 
            : Colors.red.withOpacity(0.05),
      ),
    );
  }

  Future<void> _searchWasteSeparation(String itemName) async {
    setState(() {
      _isSearching = true;
      _searchResults.clear();
    });

    try {
      final result = await WasteSeparationService.searchWasteSeparation(
        itemName,
        region: _selectedRegion?.name,
      );
      
      if (result != null) {
        setState(() {
          _searchResults.add(result);
        });
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WasteSeparationScreen._searchWasteSeparation');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _addToHistory(WasteSeparationResult result) async {
    try {
      final history = WasteSeparationHistory(
        id: 'history_${DateTime.now().millisecondsSinceEpoch}',
        itemName: result.itemName,
        category: result.category,
        region: result.region,
        createdAt: DateTime.now(),
        isCorrect: true,
      );
      
      await WasteSeparationService.addToHistory(history);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('履歴に追加しました')),
      );
      
      _loadHistory();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WasteSeparationScreen._addToHistory');
    }
  }

  Future<void> _reportIncorrect(WasteSeparationResult result) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('間違いを報告'),
          content: const Text('この分別結果が間違っていることを報告しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // 履歴に追加
                final history = WasteSeparationHistory(
                  id: 'history_${DateTime.now().millisecondsSinceEpoch}',
                  itemName: result.itemName,
                  category: result.category,
                  region: result.region,
                  createdAt: DateTime.now(),
                  isCorrect: false,
                  feedback: 'ユーザーから間違い報告',
                );
                
                await WasteSeparationService.addToHistory(history);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('フィードバックを送信しました')),
                );
                
                _loadHistory();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('報告'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadHistory() async {
    try {
      final history = await WasteSeparationService.getHistory(
        region: _selectedRegion?.name,
      );
      setState(() {
        _history = history;
      });
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WasteSeparationScreen._loadHistory');
    }
  }
}
