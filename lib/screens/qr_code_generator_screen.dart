import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/food_item.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../models/recipe.dart';
import '../services/qr_code_service.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';

class QRCodeGeneratorScreen extends StatefulWidget {
  const QRCodeGeneratorScreen({super.key});

  @override
  State<QRCodeGeneratorScreen> createState() => _QRCodeGeneratorScreenState();
}

class _QRCodeGeneratorScreenState extends State<QRCodeGeneratorScreen> {
  String _selectedType = 'food_item';
  String? _selectedItemId;
  List<FoodItem> _foodItems = [];
  List<ShoppingList> _shoppingLists = [];
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String? _qrData;
  bool _isGeneratingQR = false;

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
      final foodItems = await DatabaseService.getAllFoodItems();
      final shoppingLists = await DatabaseService.getAllShoppingLists();
      
      // モックレシピデータを取得（Web版の場合）
      final recipes = <Recipe>[];
      for (int i = 0; i < 3; i++) {
        final recipe = await _getMockRecipe(i);
        if (recipe != null) {
          recipes.add(recipe);
        }
      }

      setState(() {
        _foodItems = foodItems;
        _shoppingLists = shoppingLists;
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeGeneratorScreen._loadData');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // モックレシピデータ（Web版用）
  Future<Recipe?> _getMockRecipe(int index) async {
    final mockRecipes = [
      Recipe(
        recipeId: '52874',
        title: 'Chicken Fajitas',
        category: 'Chicken',
        area: 'Mexican',
        instructions: '1. Prepare the chicken and vegetables.\n2. Heat a large skillet over medium-high heat.\n3. Cook the chicken until golden brown.\n4. Add vegetables and cook until tender.\n5. Serve with warm tortillas.',
        ingredients: ['Chicken breast', 'Bell peppers', 'Onions', 'Tortillas', 'Sour cream', 'Cheese'],
        imageUrl: 'https://www.themealdb.com/images/media/meals/583c468d96f43851d60e50e6d4e6a9a3.jpg',
        cachedDate: DateTime.now(),
      ),
      Recipe(
        recipeId: '52772',
        title: 'Spaghetti Bolognese',
        category: 'Pasta',
        area: 'Italian',
        instructions: '1. Cook spaghetti according to package directions.\n2. In a large saucepan, cook ground beef until browned.\n3. Add onion and garlic, cook until soft.\n4. Add tomatoes and simmer for 30 minutes.\n5. Serve with spaghetti and parmesan cheese.',
        ingredients: ['Spaghetti', 'Ground beef', 'Tomatoes', 'Onion', 'Garlic', 'Parmesan cheese'],
        imageUrl: 'https://www.themealdb.com/images/media/meals/utskpsxsrqrvrvhsqohvvykuwjucpqld/meal-1.jpg',
        cachedDate: DateTime.now(),
      ),
      Recipe(
        recipeId: '52959',
        title: 'Beef and Broccoli Stir Fry',
        category: 'Beef',
        area: 'Chinese',
        instructions: '1. Heat oil in a large skillet or wok over high heat.\n2. Add beef and stir-fry until browned.\n3. Add broccoli and stir-fry for 3-4 minutes.\n4. Add sauce and toss to combine.\n5. Serve over rice.',
        ingredients: ['Beef', 'Broccoli', 'Soy sauce', 'Ginger', 'Garlic', 'Rice'],
        imageUrl: 'https://www.themealdb.com/images/media/meals/wyrppptcpuecxeexqkqgqyvqvljzx/meal-1.jpg',
        cachedDate: DateTime.now(),
      ),
    ];
    
    return index < mockRecipes.length ? mockRecipes[index] : null;
  }

  Future<void> _generateQRCode() async {
    if (_selectedItemId == null) return;

    setState(() {
      _isGeneratingQR = true;
    });

    try {
      String qrData = '';

      switch (_selectedType) {
        case 'food_item':
          final foodItem = _foodItems.firstWhere((item) => item.id == _selectedItemId);
          qrData = await QRCodeService.generateFoodItemQRCode(foodItem);
          break;
        case 'shopping_list':
          final shoppingList = _shoppingLists.firstWhere((list) => list.id == _selectedItemId);
          final items = _selectedItemId != null ? await DatabaseService.getShoppingItems(_selectedItemId!) : <ShoppingItem>[];
          qrData = await QRCodeService.generateShoppingListQRCode(shoppingList, items);
          break;
        case 'recipe':
          final recipe = _recipes.firstWhere((recipe) => recipe.recipeId == _selectedItemId);
          qrData = await QRCodeService.generateRecipeQRCode(recipe);
          break;
        case 'inventory':
          qrData = await QRCodeService.generateInventoryQRCode(_foodItems);
          break;
        case 'purchase':
          qrData = await QRCodeService.generatePurchaseQRCode(_foodItems);
          break;
      }

      setState(() {
        _qrData = qrData;
        _isGeneratingQR = false;
      });
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeGeneratorScreen._generateQRCode');
      setState(() {
        _isGeneratingQR = false;
      });
    }
  }

  Future<void> _shareQRCode() async {
    if (_qrData == null) return;

    try {
      await QRCodeService.shareQRCode(_qrData ?? '', title: '食品ロス削減アプリ QRコード');
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeGeneratorScreen._shareQRCode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRコード生成'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タイプ選択
                  _buildTypeSelector(),
                  const SizedBox(height: 20),
                  
                  // アイテム選択
                  _buildItemSelector(),
                  const SizedBox(height: 20),
                  
                  // 生成ボタン
                  _buildGenerateButton(),
                  const SizedBox(height: 20),
                  
                  // QRコード表示
                  if (_qrData != null) _buildQRCodeDisplay(),
                ],
              ),
            ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QRコードの種類',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildTypeChip('food_item', '食材情報'),
            _buildTypeChip('shopping_list', '買い物リスト'),
            _buildTypeChip('recipe', 'レシピ'),
            _buildTypeChip('inventory', '在庫管理'),
            _buildTypeChip('purchase', '購入管理'),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedType == type,
      onSelected: (selected) {
        setState(() {
          _selectedType = type;
          _selectedItemId = null;
          _qrData = null;
        });
      },
      backgroundColor: _selectedType == type ? Colors.green : Colors.grey[200],
      selectedColor: Colors.white,
      labelStyle: TextStyle(
        color: _selectedType == type ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildItemSelector() {
    List<Widget> items = [];

    switch (_selectedType) {
      case 'food_item':
        items = _foodItems.map((item) => ListTile(
          title: Text(item.name),
          subtitle: Text('期限: ${item.expiryDate.month}/${item.expiryDate.day}'),
          trailing: Radio<String>(
            value: item.id,
            groupValue: _selectedItemId,
            onChanged: (value) {
              setState(() {
                _selectedItemId = value;
                _qrData = null;
              });
            },
          ),
        )).toList();
        break;
      case 'shopping_list':
        items = _shoppingLists.map((list) => ListTile(
          title: Text(list.name),
          subtitle: Text('作成日: ${list.createdDate.month}/${list.createdDate.day}'),
          trailing: Radio<String>(
            value: list.id,
            groupValue: _selectedItemId,
            onChanged: (value) {
              setState(() {
                _selectedItemId = value;
                _qrData = null;
              });
            },
          ),
        )).toList();
        break;
      case 'recipe':
        items = _recipes.map((recipe) => ListTile(
          title: Text(recipe.title),
          subtitle: Text(recipe.category ?? ''),
          trailing: Radio<String>(
            value: recipe.recipeId,
            groupValue: _selectedItemId,
            onChanged: (value) {
              setState(() {
                _selectedItemId = value;
                _qrData = null;
              });
            },
          ),
        )).toList();
        break;
      case 'inventory':
      case 'purchase':
        items = [
          ListTile(
            title: Text(_selectedType == 'inventory' ? '全在庫データ' : '全購入データ'),
            subtitle: Text('${_foodItems.length}件のデータ'),
            trailing: Radio<String>(
              value: 'all',
              groupValue: _selectedItemId,
              onChanged: (value) {
                setState(() {
                  _selectedItemId = value;
                  _qrData = null;
                });
              },
            ),
          ),
        ];
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getItemSelectorTitle(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: items.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'データがありません',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              : Column(children: items),
        ),
      ],
    );
  }

  String _getItemSelectorTitle() {
    switch (_selectedType) {
      case 'food_item':
        return '食材を選択';
      case 'shopping_list':
        return '買い物リストを選択';
      case 'recipe':
        return 'レシピを選択';
      case 'inventory':
        return '在庫データを選択';
      case 'purchase':
        return '購入データを選択';
      default:
        return 'アイテムを選択';
    }
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _selectedItemId != null && !_isGeneratingQR
            ? _generateQRCode
            : null,
        icon: _isGeneratingQR
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.qr_code),
        label: Text(_isGeneratingQR ? '生成中...' : 'QRコード生成'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildQRCodeDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '生成されたQRコード',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
            children: [
              QrImageView(
                data: _qrData!,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareQRCode,
                      icon: const Icon(Icons.share),
                      label: const Text('共有'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _qrData = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('再生成'),
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
        ),
      ],
    );
  }
}
