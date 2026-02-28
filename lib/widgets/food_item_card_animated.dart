import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_item.dart';

class FoodItemCardAnimated extends StatefulWidget {
  final FoodItem foodItem;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onConsume;

  const FoodItemCardAnimated({
    super.key,
    required this.foodItem,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onConsume,
  });

  @override
  State<FoodItemCardAnimated> createState() => _FoodItemCardAnimatedState();
}

class _FoodItemCardAnimatedState extends State<FoodItemCardAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    // 初回表示時のアニメーション
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.reverse();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.forward();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Card(
              elevation: _isPressed ? 8 : 2,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _getStatusColor(widget.foodItem).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        _getStatusColor(widget.foodItem).withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // 画像またはアイコン
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _getStatusColor(widget.foodItem).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: widget.foodItem.imagePath != null
                                ? Image.network(
                                    widget.foodItem.imagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        _getCategoryIcon(widget.foodItem.category),
                                        size: 30,
                                        color: _getStatusColor(widget.foodItem),
                                      );
                                    },
                                  )
                                : Icon(
                                    _getCategoryIcon(widget.foodItem.category),
                                    size: 30,
                                    color: _getStatusColor(widget.foodItem),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 食材情報
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.foodItem.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '数量: ${widget.foodItem.quantity}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    _getStorageLocationIcon(widget.foodItem.storageLocation),
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.foodItem.storageLocation,
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
                        // 期限ステータス
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.foodItem),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(widget.foodItem),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // アクションボタン
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                widget.onEdit();
                                break;
                              case 'consume':
                                widget.onConsume();
                                break;
                              case 'delete':
                                widget.onDelete();
                                break;
                            }
                          },
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.grey[600],
                          ),
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(FoodItem foodItem) {
    switch (foodItem.expiryStatus) {
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case '野菜':
        return Icons.eco;
      case '果物':
        return Icons.apple;
      case '肉':
        return Icons.lunch_dining;
      case '魚':
        return Icons.set_meal;
      case '乳製品':
        return Icons.egg;
      case '調味料':
        return Icons.restaurant;
      default:
        return Icons.shopping_basket;
    }
  }

  IconData _getStorageLocationIcon(String location) {
    switch (location.toLowerCase()) {
      case '冷蔵庫':
        return Icons.ac_unit;
      case '冷凍庫':
        return Icons.snowing;
      case '常温':
        return Icons.wb_sunny;
      default:
        return Icons.kitchen;
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
