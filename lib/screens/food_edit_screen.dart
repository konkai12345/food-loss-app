import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/food_item.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';

class FoodEditScreen extends StatefulWidget {
  final FoodItem foodItem;

  const FoodEditScreen({super.key, required this.foodItem});

  @override
  State<FoodEditScreen> createState() => _FoodEditScreenState();
}

class _FoodEditScreenState extends State<FoodEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchaseStoreController = TextEditingController();
  final _memoController = TextEditingController();
  
  late DateTime _expiryDate;
  late String _selectedCategory;
  late String _selectedStorage;
  String? _imagePath;

  final List<String> _categories = [
    '野菜', '果物', '肉', '魚', '乳製品', '調味料', 'その他'
  ];

  final List<String> _storageLocations = [
    '冷蔵庫', '冷凍庫', '常温'
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final foodItem = widget.foodItem;
    _nameController.text = foodItem.name;
    _quantityController.text = foodItem.quantity.toString();
    _priceController.text = foodItem.price?.toString() ?? '';
    _purchaseStoreController.text = foodItem.purchaseStore ?? '';
    _memoController.text = foodItem.memo ?? '';
    _expiryDate = foodItem.expiryDate;
    _selectedCategory = foodItem.category;
    _selectedStorage = foodItem.storageLocation;
    _imagePath = foodItem.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _purchaseStoreController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _updateFoodItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final updatedFoodItem = widget.foodItem.copyWith(
        name: _nameController.text,
        expiryDate: _expiryDate,
        quantity: int.parse(_quantityController.text),
        storageLocation: _selectedStorage,
        category: _selectedCategory,
        memo: _memoController.text.isEmpty ? null : _memoController.text,
        imagePath: _imagePath,
        price: _priceController.text.isEmpty ? null : double.parse(_priceController.text),
        purchaseStore: _purchaseStoreController.text.isEmpty ? null : _purchaseStoreController.text,
      );

      await DatabaseService.updateFoodItem(updatedFoodItem);
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.showErrorSnackBar(context, '食材の更新に失敗しました');
      }
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FoodEditScreen._updateFoodItem');
    }
  }

  Future<void> _deleteFoodItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: Text('${widget.foodItem.name}を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.deleteFoodItem(widget.foodItem.id);
        
        if (mounted) {
          Navigator.pop(context, true);
          AppErrorHandler.showSuccessSnackBar(context, '食材を削除しました');
        }
      } catch (e) {
        if (mounted) {
          AppErrorHandler.showErrorSnackBar(context, '食材の削除に失敗しました');
        }
        AppErrorHandler.handleError(e, StackTrace.current, context: 'FoodEditScreen._deleteFoodItem');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('食材を編集'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteFoodItem,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 食材名
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '食材名',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '食材名を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // カテゴリ
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'カテゴリ',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 数量
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: '数量',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '数量を入力してください';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return '有効な数量を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 保管場所
            DropdownButtonFormField<String>(
              value: _selectedStorage,
              decoration: const InputDecoration(
                labelText: '保管場所',
                border: OutlineInputBorder(),
              ),
              items: _storageLocations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStorage = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 賞味期限
            ListTile(
              title: const Text('賞味期限'),
              subtitle: Text('${_expiryDate.year}/${_expiryDate.month}/${_expiryDate.day}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _expiryDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _expiryDate = date;
                  });
                }
              },
            ),
            const Divider(),
            const SizedBox(height: 16),

            // 価格（オプション）
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: '価格（オプション）',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // 購入店（オプション）
            TextFormField(
              controller: _purchaseStoreController,
              decoration: const InputDecoration(
                labelText: '購入店（オプション）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // メモ（オプション）
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: 'メモ（オプション）',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // 保存ボタン
            ElevatedButton(
              onPressed: _updateFoodItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('更新'),
            ),
          ],
        ),
      ),
    );
  }
}
