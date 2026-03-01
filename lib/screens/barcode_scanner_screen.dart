import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/food_item.dart';
import '../models/product_info.dart';
import '../services/cache_service.dart';
import '../services/database_service.dart';
import '../themes/natural_eco_theme_fixed.dart';
import '../widgets/natural_eco_components.dart';
import '../utils/error_handler.dart';

// モックデータメソッド
Future<ProductInfo?> _getMockProductInfo(String barcode) async {
  // モック商品情報を返す
  return ProductInfo(
    barcode: barcode,
    productName: 'モック商品 ($barcode)',
    brand: 'テストブランド',
    categories: ['食品'],
    nutriments: {
      'calories': 100,
      'protein': 10,
      'carbs': 20,
      'fat': 5,
    },
    cachedDate: DateTime.now(),
  );
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isScanning = true;
  String? _lastScannedBarcode;
  Map<String, dynamic>? _productInfo;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('バーコードスキャン'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // スキャナー部分
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MobileScanner(
                  controller: MobileScannerController(
                    detectionSpeed: DetectionSpeed.normal,
                    facing: CameraFacing.back,
                  ),
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (_isScanning && barcode.rawValue != null) {
                        _handleBarcodeScanned(barcode.rawValue!);
                        break;
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          
          // 情報表示部分
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_lastScannedBarcode != null) ...[
                    Text(
                      'スキャン済みバーコード:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      _lastScannedBarcode!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (_isLoading) ...[
                    const Center(child: CircularProgressIndicator()),
                  ] else if (_productInfo != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '商品情報',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _productInfo!['productName'] ?? '不明',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_productInfo!['brand'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'ブランド: ${_productInfo!['brand']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                          if (_productInfo!['categories'] != null && _productInfo!['categories'].isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'カテゴリ: ${(_productInfo!['categories'] as List).join(', ')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context, {
                                'barcode': _lastScannedBarcode,
                                'productName': _productInfo!['productName'],
                              });
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('この商品を追加'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _resetScanner,
                          icon: const Icon(Icons.refresh),
                          label: const Text('再スキャン'),
                        ),
                      ],
                    ),
                  ] else if (_lastScannedBarcode != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '商品情報が見つかりませんでした',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '手動で商品名を入力してください',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showManualInputDialog,
                            icon: const Icon(Icons.edit),
                            label: const Text('手動入力'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _resetScanner,
                          icon: const Icon(Icons.refresh),
                          label: const Text('再スキャン'),
                        ),
                      ],
                    ),
                  ] else ...[
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'バーコードをスキャンしてください',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBarcodeScanned(String barcode) async {
    if (_lastScannedBarcode == barcode) return;

    setState(() {
      _isScanning = false;
      _lastScannedBarcode = barcode;
      _isLoading = true;
      _productInfo = null;
    });

    try {
      // まずキャッシュを確認
      final cachedProduct = await CacheService.getCachedProductInfo(barcode);
      
      if (cachedProduct != null) {
        setState(() {
          _productInfo = cachedProduct.toJson();
          _isLoading = false;
        });
      } else {
        // APIで商品情報を検索
        // OpenFoodFactsサービスは削除されたため、モックデータを返す
        final productInfo = await _getMockProductInfo(barcode);
        
        if (productInfo != null) {
          // キャッシュに保存
          await CacheService.cacheProductInfo(productInfo);
          
          setState(() {
            _productInfo = productInfo.toJson();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'BarcodeScannerScreen._handleBarcodeScanned');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _lastScannedBarcode = null;
      _productInfo = null;
      _isLoading = false;
    });
  }

  void _showManualInputDialog() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('商品名を入力'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '商品名',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                Navigator.pop(context, {
                  'barcode': _lastScannedBarcode,
                  'productName': controller.text,
                });
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }
}
