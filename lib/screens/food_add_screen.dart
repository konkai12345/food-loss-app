import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/food_item.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';

class FoodAddScreen extends StatefulWidget {
  const FoodAddScreen({super.key});

  @override
  State<FoodAddScreen> createState() => _FoodAddScreenState();
}

class _FoodAddScreenState extends State<FoodAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchaseStoreController = TextEditingController();
  final _memoController = TextEditingController();
  
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  DateTime _registrationDate = DateTime.now();
  String _selectedCategory = '野菜';
  String _selectedStorage = '冷蔵庫';
  String? _imagePath;

  final List<String> _categories = [
    '野菜', '果物', '肉', '魚', '乳製品', '調味料', 'その他'
  ];

  final List<String> _storageLocations = [
    '冷蔵庫', '冷凍庫', '常温'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _purchaseStoreController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _saveFoodItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final foodItem = FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        expiryDate: _expiryDate,
        registrationDate: _registrationDate,
        quantity: int.parse(_quantityController.text),
        storageLocation: _selectedStorage,
        category: _selectedCategory,
        memo: _memoController.text.isEmpty ? null : _memoController.text,
        imagePath: _imagePath,
        price: _priceController.text.isEmpty ? null : double.parse(_priceController.text),
        purchaseStore: _purchaseStoreController.text.isEmpty ? null : _purchaseStoreController.text,
      );

      await DatabaseService.addFoodItem(foodItem);
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.showErrorSnackBar(context, '食材の追加に失敗しました');
      }
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FoodAddScreen._saveFoodItem');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('食材を追加'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
              onPressed: _saveFoodItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
