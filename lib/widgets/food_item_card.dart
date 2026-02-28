import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_item.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onConsume;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onConsume,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 上部：画像と基本情報
              Row(
                children: [
                  // 画像プレースホルダー
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: foodItem.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              foodItem.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultIcon();
                              },
                            ),
                          )
                        : _buildDefaultIcon(),
                  ),
                  const SizedBox(width: 12),
                  // 基本情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foodItem.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '数量: ${foodItem.quantity}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getStorageLocationIcon(foodItem.storageLocation),
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              foodItem.storageLocation,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 下部：期限情報とアクションボタン
              Row(
                children: [
                  // 期限情報
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(foodItem.expiryStatus),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(foodItem),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // アクションボタン
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'consume':
                          onConsume();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('編集'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'consume',
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 16),
                            SizedBox(width: 8),
                            Text('消費済み'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16),
                            SizedBox(width: 8),
                            Text('削除'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Icon(
      _getCategoryIcon(foodItem.category),
      size: 30,
      color: Colors.grey[600],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case '野菜':
        return Icons.eco;
      case '肉':
        return Icons.lunch_dining;
      case '魚':
        return Icons.set_meal;
      case '乳製品':
        return Icons.local_cafe;
      case '果物':
        return Icons.apple;
      case '調味料':
        return Icons.opacity;
      default:
        return Icons.restaurant;
    }
  }

  IconData _getStorageLocationIcon(String location) {
    switch (location) {
      case '冷蔵庫':
        return Icons.kitchen;
      case '冷凍室':
        return Icons.ac_unit;
      case '常温':
        return Icons.room;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.fresh:
        return Colors.green;
      case ExpiryStatus.soon:
        return Colors.orange;
      case ExpiryStatus.urgent:
        return Colors.deepOrange;
      case ExpiryStatus.expired:
        return Colors.red;
    }
  }

  String _getStatusText(FoodItem foodItem) {
    final days = foodItem.daysUntilExpiry;
    final dateFormat = DateFormat('MM/dd');
    
    switch (foodItem.expiryStatus) {
      case ExpiryStatus.fresh:
        return '期限: ${dateFormat.format(foodItem.expiryDate)}';
      case ExpiryStatus.soon:
        return 'あと$days日';
      case ExpiryStatus.urgent:
        return '明日まで';
      case ExpiryStatus.expired:
        return '期限切れ';
    }
  }
}
