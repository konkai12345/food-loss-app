import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/food_item.dart';
import '../services/database_service.dart';

class AddFoodScreen extends StatefulWidget {
  final FoodItem? foodItem;

  const AddFoodScreen({super.key, this.foodItem});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _memoController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchaseStoreController = TextEditingController();

  DateTime? _expiryDate;
  String _selectedStorageLocation = '冷蔵庫';
  String _selectedCategory = '野菜';
  String? _imagePath;

  final List<String> _storageLocations = ['冷蔵庫', '冷凍室', '常温'];
  final List<String> _categories = ['野菜', '肉', '魚', '乳製品', '果物', '調味料', 'その他'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.foodItem != null) {
      _initializeWithExistingItem();
    }
  }

  void _initializeWithExistingItem() {
    final item = widget.foodItem!;
    _nameController.text = item.name;
    _quantityController.text = item.quantity.toString();
    _memoController.text = item.memo ?? '';
    _priceController.text = item.price?.toString() ?? '';
    _purchaseStoreController.text = item.purchaseStore ?? '';
    _expiryDate = item.expiryDate;
    _selectedStorageLocation = item.storageLocation;
    _selectedCategory = item.category;
    _imagePath = item.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _memoController.dispose();
    _priceController.dispose();
    _purchaseStoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodItem == null ? '食材を追加' : '食材を編集'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (widget.foodItem != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteItem,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 画像追加
              _buildImageSection(),
              const SizedBox(height: 16),
              
              // 基本情報
              _buildBasicInfoSection(),
              const SizedBox(height: 16),
              
              // 詳細情報
              _buildDetailedInfoSection(),
              const SizedBox(height: 16),
              
              // 保存ボタン
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '写真',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: _imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          _imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 40, color: Colors.grey),
        SizedBox(height: 8),
        Text('タップして写真を追加', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '基本情報',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // 食材名
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '食材名 *',
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
            
            // 賞味期限
            InkWell(
              onTap: _selectExpiryDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '賞味期限 *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _expiryDate != null
                      ? DateFormat('yyyy/MM/dd').format(_expiryDate!)
                      : '日付を選択してください',
                  style: TextStyle(
                    color: _expiryDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 数量
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: '数量 *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '数量を入力してください';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return '正しい数量を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 保管場所
            DropdownButtonFormField<String>(
              value: _selectedStorageLocation,
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
                  _selectedStorageLocation = value!;
                });
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
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '詳細情報',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // メモ
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: 'メモ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // 価格
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: '価格',
                border: OutlineInputBorder(),
                prefixText: '¥',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // 購入店
            TextFormField(
              controller: _purchaseStoreController,
              decoration: const InputDecoration(
                labelText: '購入店',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveFoodItem,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(widget.foodItem == null ? '追加' : '更新'),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('画像の選択に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _saveFoodItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('賞味期限を選択してください')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final foodItem = FoodItem(
        id: widget.foodItem?.id ?? const Uuid().v4(),
        name: _nameController.text,
        expiryDate: _expiryDate!,
        registrationDate: widget.foodItem?.registrationDate ?? DateTime.now(),
        quantity: int.parse(_quantityController.text),
        storageLocation: _selectedStorageLocation,
        category: _selectedCategory,
        memo: _memoController.text.isEmpty ? null : _memoController.text,
        imagePath: _imagePath,
        price: _priceController.text.isEmpty ? null : double.tryParse(_priceController.text),
        purchaseStore: _purchaseStoreController.text.isEmpty ? null : _purchaseStoreController.text,
      );

      if (widget.foodItem == null) {
        await DatabaseService.addFoodItem(foodItem);
      } else {
        await DatabaseService.updateFoodItem(foodItem);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.foodItem == null ? '食材を追加しました' : '食材を更新しました'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteItem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: const Text('この食材を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await DatabaseService.deleteFoodItem(widget.foodItem!.id);
                if (mounted) {
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('削除しました')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('削除に失敗しました: $e')),
                  );
                }
              }
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
