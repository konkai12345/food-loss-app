import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../models/food_item.dart';
import '../themes/natural_eco_theme.dart';
import '../widgets/natural_eco_components.dart';
import '../utils/date_utils.dart';

class AddFoodScreenNaturalEco extends StatefulWidget {
  const AddFoodScreenNaturalEco({Key? key}) : super(key: key);

  @override
  State<AddFoodScreenNaturalEco> createState() => _AddFoodScreenNaturalEcoState();
}

class _AddFoodScreenNaturalEcoState extends State<AddFoodScreenNaturalEco>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _memoController = TextEditingController();
  
  String _selectedCategory = '野菜';
  String _selectedLocation = '冷蔵庫';
  String _selectedUnit = '個';
  DateTime _selectedExpiryDate = DateTime.now().add(const Duration(days: 7));
  String? _selectedImagePath;
  bool _isLoading = false;

  late AnimationController _formAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _formAnimation;
  late Animation<double> _buttonAnimation;

  final List<String> _categories = [
    '野菜', '果物', '肉類', '魚介類', '乳製品', '調味料', 'その他'
  ];

  final List<String> _locations = [
    '冷蔵庫', '冷凍庫', '常温', 'その他'
  ];

  final List<String> _units = [
    '個', 'g', 'kg', 'ml', 'L', '本', '袋', '箱'
  ];

  @override
  void initState() {
    super.initState();
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.elasticOut,
    ));

    // アニメーションを開始
    _formAnimationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _memoController.dispose();
    _formAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _selectedImagePath = image!.path;
      });
    }
  }

  Future<void> _saveFood() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final foodItem = FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        expiryDate: _selectedExpiryDate,
        registrationDate: DateTime.now(),
        quantity: int.parse(_quantityController.text),
        unit: _selectedUnit,
        location: _selectedLocation,
        memo: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
        imagePath: _selectedImagePath,
      );

      await Provider.of<FoodProvider>(context, listen: false)
          .addFoodItem(foodItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('食品を追加しました'),
              ],
            ),
            backgroundColor: NaturalEcoTheme.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Text('エラーが発生しました'),
              ],
            ),
            backgroundColor: NaturalEcoTheme.darkGrey,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NaturalEcoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('食品を追加'),
          backgroundColor: NaturalEcoTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AnimatedBuilder(
            animation: _formAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (1 - _formAnimation.value) * 50),
                child: Opacity(
                  opacity: _formAnimation.value,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 画像選択
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: NaturalEcoTheme.lightGrey,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: NaturalEcoTheme.woodBrown.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: _selectedImagePath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Image.asset(
                                        _selectedImagePath!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: NaturalEcoTheme.mediumGrey,
                                          );
                                        },
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 40,
                                          color: NaturalEcoTheme.mediumGrey,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '写真を追加',
                                          style: Theme.of(context).textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 基本情報
                        NaturalEcoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '基本情報',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: NaturalEcoTheme.primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: '食品名',
                                  hintText: '例：新鮮なトマト',
                                  prefixIcon: Icon(Icons.restaurant),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return '食品名は必須です';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedCategory,
                                      decoration: const InputDecoration(
                                        labelText: 'カテゴリ',
                                        prefixIcon: Icon(Icons.category),
                                      ),
                                      items: _categories.map((category) {
                                        return DropdownMenuItem(
                                          value: category,
                                          child: Row(
                                            children: [
                                              NaturalEcoCategoryIcon(
                                                category: category,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(category),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCategory = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _quantityController,
                                      decoration: const InputDecoration(
                                        labelText: '数量',
                                        hintText: '例：2',
                                        prefixIcon: Icon(Icons.scale),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return '数量は必須です';
                                        }
                                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                          return '正しい数量を入力してください';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedUnit,
                                      decoration: const InputDecoration(
                                        labelText: '単位',
                                        prefixIcon: Icon(Icons.straighten),
                                      ),
                                      items: _units.map((unit) {
                                        return DropdownMenuItem(
                                          value: unit,
                                          child: Text(unit),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedUnit = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedLocation,
                                      decoration: const InputDecoration(
                                        labelText: '保管場所',
                                        prefixIcon: Icon(Icons.location_on),
                                      ),
                                      items: _locations.map((location) {
                                        return DropdownMenuItem(
                                          value: location,
                                          child: Text(location),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedLocation = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 期限設定
                        NaturalEcoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '消費期限',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: NaturalEcoTheme.primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                leading: const Icon(Icons.event),
                                title: Text(
                                  DateUtils.formatDate(_selectedExpiryDate),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                subtitle: Text(
                                  '残り${_selectedExpiryDate.difference(DateTime.now()).inDays}日',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: NaturalEcoTheme.primaryGreen,
                                  ),
                                ),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedExpiryDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _selectedExpiryDate = date;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // メモ
                        NaturalEcoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'メモ',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: NaturalEcoTheme.primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _memoController,
                                decoration: const InputDecoration(
                                  labelText: 'メモ（任意）',
                                  hintText: '例：特売品で購入',
                                  prefixIcon: Icon(Icons.note),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 保存ボタン
                        AnimatedBuilder(
                          animation: _buttonAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _buttonAnimation.value,
                              child: NaturalEcoButton(
                                text: '食品を保存',
                                icon: Icons.save,
                                isLoading: _isLoading,
                                onPressed: _saveFood,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
