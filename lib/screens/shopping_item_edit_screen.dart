import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_provider.dart';
import 'package:provider/provider.dart';

class ShoppingItemEditScreen extends StatefulWidget {
  final ShoppingItem? editingItem;
  final bool isEditing;

  const ShoppingItemEditScreen({
    super.key,
    this.editingItem,
    this.isEditing = false,
  });

  @override
  State<ShoppingItemEditScreen> createState() => _ShoppingItemEditScreenState();
}

class _ShoppingItemEditScreenState extends State<ShoppingItemEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime? _plannedPurchaseDate;

  @override
  void initState() {
    super.initState();
    
    // 編集モードの場合は既存データを設定
    if (widget.isEditing && widget.editingItem != null) {
      _nameController.text = widget.editingItem!.productName;
      _quantityController.text = widget.editingItem!.quantity.toString();
      _plannedPurchaseDate = widget.editingItem!.plannedPurchaseDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        final quantity = int.tryParse(_quantityController.text) ?? 1;
        
        if (widget.isEditing && widget.editingItem != null) {
          // 編集モード
          final updatedItem = widget.editingItem!.copyWith(
            productName: _nameController.text,
            quantity: quantity,
            plannedPurchaseDate: _plannedPurchaseDate,
          );
          
          await context.read<ShoppingProvider>().updateShoppingItem(updatedItem);
        } else {
          // 新規追加モード
          await context.read<ShoppingProvider>().addShoppingItem(
            _nameController.text,
            quantity: quantity,
            plannedPurchaseDate: _plannedPurchaseDate,
          );
        }
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存に失敗しました: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '買い物アイテム編集' : '買い物アイテム追加'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '商品名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '商品名を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return '1以上の数字を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_plannedPurchaseDate != null 
                    ? '購入予定日: ${_plannedPurchaseDate!.year}/${_plannedPurchaseDate!.month}/${_plannedPurchaseDate!.day}'
                    : '購入予定日を設定'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _plannedPurchaseDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _plannedPurchaseDate = selectedDate;
                    });
                  }
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.isEditing ? '更新' : '追加',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
