import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';

import '../config/app_config.dart';
import '../models/game_models.dart';

class YooKassaService {
  static final YooKassaService _instance = YooKassaService._internal();
  factory YooKassaService() => _instance;
  YooKassaService._internal();

  late Dio _dio;
  String? _idempotenceKey;

  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.yookassaApiUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${_getAuthHeader()}',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: AppConfig.enableLogging,
      responseBody: AppConfig.enableLogging,
    ));
  }

  String _getAuthHeader() {
    final credentials = '${AppConfig.yookassaShopId}:${AppConfig.yookassaSecretKey}';
    return base64Encode(utf8.encode(credentials));
  }

  String _generateIdempotenceKey() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Create Payment
  Future<ApiResponse<YooKassaPayment>> createPayment({
    required String playerId,
    required int amount,
    required String description,
    required String returnUrl,
    required String successUrl,
    required String failureUrl,
  }) async {
    try {
      _idempotenceKey = _generateIdempotenceKey();
      
      final paymentData = {
        'amount': {
          'value': (amount / 100).toStringAsFixed(2),
          'currency': 'RUB',
        },
        'confirmation': {
          'type': 'redirect',
          'return_url': returnUrl,
        },
        'capture': true,
        'description': description,
        'metadata': {
          'playerId': playerId,
          'timestamp': DateTime.now().toIso8601String(),
        },
        'receipt': {
          'customer': {
            'email': 'player@touristoo.run',
          },
          'items': [
            {
              'description': description,
              'quantity': '1',
              'amount': {
                'value': (amount / 100).toStringAsFixed(2),
                'currency': 'RUB',
              },
              'vat_code': 1,
              'payment_subject': 'payment',
              'payment_mode': 'full_payment',
            },
          ],
        },
      };

      final response = await _dio.post(
        '/payments',
        data: paymentData,
        options: Options(
          headers: {
            'Idempotence-Key': _idempotenceKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final payment = YooKassaPayment.fromJson(response.data);
        return ApiResponse<YooKassaPayment>(
          success: true,
          data: payment,
        );
      } else {
        return ApiResponse<YooKassaPayment>(
          success: false,
          error: 'Payment creation failed',
        );
      }
    } catch (e) {
      return ApiResponse<YooKassaPayment>(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Get Payment Status
  Future<ApiResponse<YooKassaPayment>> getPayment(String paymentId) async {
    try {
      final response = await _dio.get('/payments/$paymentId');
      
      if (response.statusCode == 200) {
        final payment = YooKassaPayment.fromJson(response.data);
        return ApiResponse<YooKassaPayment>(
          success: true,
          data: payment,
        );
      } else {
        return ApiResponse<YooKassaPayment>(
          success: false,
          error: 'Failed to get payment status',
        );
      }
    } catch (e) {
      return ApiResponse<YooKassaPayment>(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Cancel Payment
  Future<ApiResponse<YooKassaPayment>> cancelPayment(String paymentId) async {
    try {
      _idempotenceKey = _generateIdempotenceKey();
      
      final response = await _dio.post(
        '/payments/$paymentId/cancel',
        options: Options(
          headers: {
            'Idempotence-Key': _idempotenceKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final payment = YooKassaPayment.fromJson(response.data);
        return ApiResponse<YooKassaPayment>(
          success: true,
          data: payment,
        );
      } else {
        return ApiResponse<YooKassaPayment>(
          success: false,
          error: 'Payment cancellation failed',
        );
      }
    } catch (e) {
      return ApiResponse<YooKassaPayment>(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Create Refund
  Future<ApiResponse<YooKassaRefund>> createRefund({
    required String paymentId,
    required int amount,
    required String description,
  }) async {
    try {
      _idempotenceKey = _generateIdempotenceKey();
      
      final refundData = {
        'amount': {
          'value': (amount / 100).toStringAsFixed(2),
          'currency': 'RUB',
        },
        'payment_id': paymentId,
        'description': description,
      };

      final response = await _dio.post(
        '/refunds',
        data: refundData,
        options: Options(
          headers: {
            'Idempotence-Key': _idempotenceKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final refund = YooKassaRefund.fromJson(response.data);
        return ApiResponse<YooKassaRefund>(
          success: true,
          data: refund,
        );
      } else {
        return ApiResponse<YooKassaRefund>(
          success: false,
          error: 'Refund creation failed',
        );
      }
    } catch (e) {
      return ApiResponse<YooKassaRefund>(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Verify Webhook
  bool verifyWebhook(String body, String signature) {
    try {
      final expectedSignature = _generateSignature(body, AppConfig.yookassaSecretKey);
      return signature == expectedSignature;
    } catch (e) {
      return false;
    }
  }

  String _generateSignature(String data, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }
}

// YooKassa Models
class YooKassaPayment {
  final String id;
  final String status;
  final YooKassaAmount amount;
  final String description;
  final String? confirmationUrl;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const YooKassaPayment({
    required this.id,
    required this.status,
    required this.amount,
    required this.description,
    this.confirmationUrl,
    required this.createdAt,
    required this.metadata,
  });

  factory YooKassaPayment.fromJson(Map<String, dynamic> json) {
    return YooKassaPayment(
      id: json['id'],
      status: json['status'],
      amount: YooKassaAmount.fromJson(json['amount']),
      description: json['description'],
      confirmationUrl: json['confirmation']?['confirmation_url'],
      createdAt: DateTime.parse(json['created_at']),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'amount': amount.toJson(),
      'description': description,
      'confirmation_url': confirmationUrl,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  bool get isSucceeded => status == 'succeeded';
  bool get isCanceled => status == 'canceled';
  bool get isWaitingForCapture => status == 'waiting_for_capture';
  bool get isPending => status == 'pending';
}

class YooKassaAmount {
  final String value;
  final String currency;

  const YooKassaAmount({
    required this.value,
    required this.currency,
  });

  factory YooKassaAmount.fromJson(Map<String, dynamic> json) {
    return YooKassaAmount(
      value: json['value'],
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'currency': currency,
    };
  }

  int get valueInKopecks => (double.parse(value) * 100).round();
}

class YooKassaRefund {
  final String id;
  final String status;
  final YooKassaAmount amount;
  final String description;
  final String paymentId;
  final DateTime createdAt;

  const YooKassaRefund({
    required this.id,
    required this.status,
    required this.amount,
    required this.description,
    required this.paymentId,
    required this.createdAt,
  });

  factory YooKassaRefund.fromJson(Map<String, dynamic> json) {
    return YooKassaRefund(
      id: json['id'],
      status: json['status'],
      amount: YooKassaAmount.fromJson(json['amount']),
      description: json['description'],
      paymentId: json['payment_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'amount': amount.toJson(),
      'description': description,
      'payment_id': paymentId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isSucceeded => status == 'succeeded';
  bool get isCanceled => status == 'canceled';
  bool get isPending => status == 'pending';
}
