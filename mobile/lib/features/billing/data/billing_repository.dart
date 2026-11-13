import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';

class BillingProduct {
  const BillingProduct({
    required this.sku,
    required this.title,
    required this.productType,
    this.creditsTc,
    this.priceUsdCents,
  });

  final String sku;
  final String title;
  final String productType;
  final int? creditsTc;
  final int? priceUsdCents;

  factory BillingProduct.fromJson(Map<String, dynamic> json) => BillingProduct(
        sku: json['sku'] as String,
        title: json['title'] as String,
        productType: json['productType'] as String,
        creditsTc: (json['creditsTc'] as num?)?.toInt(),
        priceUsdCents: (json['priceUsdCents'] as num?)?.toInt(),
      );
}

class BillingRepository {
  BillingRepository(this._dio);

  final Dio _dio;

  Future<List<BillingProduct>> products() async {
    final response = await _dio.get<List<dynamic>>('/billing/products');
    return (response.data ?? const [])
        .map((e) => BillingProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sends a purchase token to the backend for authoritative verification.
  /// In production the token comes from `in_app_purchase` / Play Billing.
  Future<Map<String, dynamic>> verifyMockPurchase(BillingProduct product) async {
    final token =
        'mock-token-${product.sku}-${DateTime.now().millisecondsSinceEpoch}';
    final response = await _dio.post<Map<String, dynamic>>(
      '/billing/purchases/verify',
      data: {
        'productId': product.sku,
        'purchaseToken': token,
        'packageName': 'com.apptrial.mobile',
      },
      options: Options(
        headers: {
          'Idempotency-Key': token,
        },
      ),
    );
    return response.data!;
  }
}

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepository(ref.watch(dioProvider));
});

/// Exposed for UI copy; real IAP uses Play Billing, not this constant.
const billingPackageHint = AppConfig.appName;
