import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';
import '../models/food_item.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;
  String? _lastScannedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRコードスキャン'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRCodeScanner(
              onQRViewCreated: (QRViewController controller) {
                controller.scannedDataStream.listen((scanData) {
                  if (scanData.code != null && !_isProcessing) {
                    _processQRCode(scanData.code!);
                  }
                });
              },
              overlay: QrScannerOverlayShape(
                borderColor: const Color(0xFF4CAF50),
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'スキャン方法:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. 食品や買い物リストのQRコードをカメラで読み取ります\n'
                    '2. 自動的にデータが解析されます\n'
                    '3. アプリにデータがインポートされます',
                    style: TextStyle(fontSize: 14),
                  ),
                  if (_lastScannedData != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '最後のスキャン:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _lastScannedData!.length > 50 
                                ? '${_lastScannedData!.substring(0, 50)}...'
                                : _lastScannedData!,
                            style: const TextStyle(fontSize: 12),
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

  Future<void> _processQRCode(String qrData) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _lastScannedData = qrData;
    });

    try {
      // JSONデータを解析
      final Map<String, dynamic> data = jsonDecode(qrData);
      final String type = data['type'] ?? '';

      switch (type) {
        case 'food_item':
          await _importFoodItem(data);
          break;
        case 'shopping_list':
          await _importShoppingList(data);
          break;
        default:
          _showError('対応していないQRコードです');
      }
    } catch (e) {
      _showError('QRコードの解析に失敗しました: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _importFoodItem(Map<String, dynamic> data) async {
    try {
      final foodItem = FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: data['name'] ?? '',
        category: data['category'] ?? '',
        expiryDate: DateTime.parse(data['expiryDate']),
        registrationDate: DateTime.parse(data['registrationDate']),
        quantity: data['quantity'] ?? 1,
        unit: data['unit'] ?? '個',
        location: data['storageLocation'] ?? '',
        memo: data['memo'],
        price: data['price']?.toDouble(),
        purchaseStore: data['purchaseStore'],
        isConsumed: data['isConsumed'] ?? false,
      );

      await DatabaseService.addFoodItem(foodItem);
      
      _showSuccess('食品情報をインポートしました');
    } catch (e) {
      _showError('食品情報のインポートに失敗しました: $e');
    }
  }

  Future<void> _importShoppingList(Map<String, dynamic> data) async {
    try {
      final listData = data['list'];
      final shoppingList = ShoppingList(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: listData['name'] ?? '',
        createdDate: DateTime.parse(listData['createdDate']),
        isCompleted: listData['isCompleted'] ?? false,
      );

      await DatabaseService.addShoppingList(shoppingList);
      
      _showSuccess('買い物リストをインポートしました');
    } catch (e) {
      _showError('買い物リストのインポートに失敗しました: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFFE57373),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
