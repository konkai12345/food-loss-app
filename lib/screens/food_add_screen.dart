import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/food_item.dart';
import '../models/product_info.dart';
import '../services/database_service.dart';
import '../services/barcode_api_service.dart';
import '../utils/error_handler.dart';
import '../widgets/barcode_scanner_dialog.dart';

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
  bool _isScanning = false;
  String? _lastScannedBarcode;
  ProductInfo? _scannedProductInfo;

  final List<String> _categories = [
    '野菜', '果物', '肉', '魚', '乳製品', '飲料', 'お菓子', '加工食品', 'パン・穀物', '調味料', 'その他'
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

  Future<ProductInfo?> _fetchProductInfo(String barcode) async {
    try {
      print('APIから商品情報を取得: $barcode');
      
      // APIから商品情報を取得
      final productInfo = await BarcodeApiService.fetchProductInfo(barcode);
      
      if (productInfo != null) {
        print('API成功: ${productInfo.productName}');
        return productInfo;
      } else {
        print('API失敗: デフォルト情報を生成');
        // API失敗時のフォールバック
        return _createFallbackProductInfo(barcode);
      }
    } catch (e) {
      print('API呼び出しエラー: $e');
      // エラー時のフォールバック
      return _createFallbackProductInfo(barcode);
    }
  }

  // フォールバック用の商品情報生成
  ProductInfo _createFallbackProductInfo(String barcode) {
    return ProductInfo(
      barcode: barcode,
      productName: '商品 ($barcode)',
      brand: '不明',
      categories: ['その他'],
      nutriments: {
        'calories': 100.0,
        'protein': 2.0,
        'carbs': 10.0,
        'fat': 1.0,
        'quantity': 1,
        'expiryDays': 30,
        'price': 100.0, // 整数価格
        'storageLocation': '常温', // デフォルト保管場所
      },
      cachedDate: DateTime.now(),
    );
  }

  void _scanBarcode() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BarcodeScannerDialog(),
        ),
      );

      if (result != null && result is String) {
        final productInfo = await _fetchProductInfo(result);
        if (mounted) {
          setState(() {
            _lastScannedBarcode = result;
            _scannedProductInfo = productInfo;
            _isScanning = false;
            
            // スキャンした情報をフォームに自動入力
            print('スキャン結果: ${productInfo?.productName}');
            print('カテゴリ: ${productInfo?.categories}');
            print('数量: ${productInfo?.nutriments?['quantity']}');
            print('賞味期限日数: ${productInfo?.nutriments?['expiryDays']}');
            print('元価格: ${productInfo?.nutriments?['price']}');
            
            _nameController.text = productInfo?.productName ?? '';
            
            // 価格を四捨五入して整数に設定
            final price = productInfo?.nutriments?['price']?.toDouble() ?? 100.0;
            final roundedPrice = price.round();
            _priceController.text = roundedPrice.toString();
            print('丸めた価格: $roundedPrice');
            
            // 数量を自動設定
            final quantity = productInfo?.nutriments?['quantity'] ?? 1;
            _quantityController.text = quantity.toString();
            print('数量設定: $quantity');
            
            // 賞味期限を正しく計算（今日からexpiryDays後）
            final expiryDays = productInfo?.nutriments?['expiryDays'] ?? 30;
            _expiryDate = DateTime.now().add(Duration(days: expiryDays));
            print('賞味期限設定: $_expiryDate (${expiryDays}日後)');
            
            // カテゴリを自動設定
            final categories = productInfo?.categories ?? [];
            print('APIから取得したカテゴリ配列: $categories');
            
            if (categories.isNotEmpty) {
              final category = categories.first;
              print('元カテゴリ: $category');
              print('カテゴリ判定開始...');
              
              // 直接マッチング
              if (_categories.contains(category)) {
                _selectedCategory = category;
                print('直接マッチング成功: $category');
              } else {
                // キーワードマッチング
                if (category.contains('野菜')) {
                  _selectedCategory = '野菜';
                  print('野菜にマッチ');
                } else if (category.contains('果物')) {
                  _selectedCategory = '果物';
                  print('果物にマッチ');
                } else if (category.contains('肉')) {
                  _selectedCategory = '肉';
                  print('肉にマッチ');
                } else if (category.contains('魚')) {
                  _selectedCategory = '魚';
                  print('魚にマッチ');
                } else if (category.contains('乳製品')) {
                  _selectedCategory = '乳製品';
                  print('乳製品にマッチ');
                } else if (category.contains('飲料')) {
                  _selectedCategory = '飲料';
                  print('飲料にマッチ');
                } else if (category.contains('お菓子') || category.contains('スナック') || category.contains('チップス')) {
                  _selectedCategory = 'お菓子';
                  print('お菓子にマッチ');
                } else if (category.contains('加工食品') || category.contains('レトルト') || category.contains('冷凍食品')) {
                  _selectedCategory = '加工食品';
                  print('加工食品にマッチ');
                } else if (category.contains('パン') || category.contains('米') || category.contains('麺')) {
                  _selectedCategory = 'パン・穀物';
                  print('パン・穀物にマッチ');
                } else if (category.contains('調味料')) {
                  _selectedCategory = '調味料';
                  print('調味料にマッチ');
                } else {
                  _selectedCategory = 'その他';
                  print('その他にマッチ');
                }
              }
              print('最終設定カテゴリ: $_selectedCategory');
            }

            // 保管場所を自動設定
            final storageLocation = productInfo?.nutriments?['storageLocation'] ?? '常温';
            if (_storageLocations.contains(storageLocation)) {
              _selectedStorage = storageLocation;
            } else {
              _selectedStorage = '常温'; // デフォルト
            }
            print('設定保管場所: $_selectedStorage');
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        AppErrorHandler.showErrorSnackBar(context, 'バーコードスキャンに失敗しました');
      }
    }
  }

  void _clearScannedInfo() {
    setState(() {
      _lastScannedBarcode = null;
      _scannedProductInfo = null;
      _nameController.clear();
      _quantityController.clear();
      _priceController.clear();
      _selectedCategory = '野菜';
      _expiryDate = DateTime.now().add(const Duration(days: 7)); // デフォルトに戻す
    });
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
        // 成功メッセージを表示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('食材を追加しました'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // 在庫管理画面に戻る（trueを返してリストを更新）
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
            // バーコードスキャン機能
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.qr_code_scanner, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'バーコードスキャン',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_scannedProductInfo != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${_scannedProductInfo!.productName} (${_lastScannedBarcode})',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: _clearScannedInfo,
                            color: Colors.red.shade700,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: _isScanning ? null : _scanBarcode,
                      icon: _isScanning 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.camera_alt),
                      label: Text(_isScanning ? 'スキャン中...' : 'バーコードをスキャン'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

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
