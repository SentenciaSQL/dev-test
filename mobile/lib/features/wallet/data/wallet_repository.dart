import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class WalletBalance {
  const WalletBalance({
    required this.availableBalance,
    required this.reservedBalance,
  });

  final int availableBalance;
  final int reservedBalance;

  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
        availableBalance: (json['availableBalance'] as num).toInt(),
        reservedBalance: (json['reservedBalance'] as num).toInt(),
      );
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.entryType,
    required this.amountTc,
    required this.balanceAfter,
    required this.createdAt,
    this.creditOrigin,
  });

  final String id;
  final String entryType;
  final int amountTc;
  final String? creditOrigin;
  final int balanceAfter;
  final String createdAt;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'] as String,
        entryType: json['entryType'] as String,
        amountTc: (json['amountTc'] as num).toInt(),
        creditOrigin: json['creditOrigin'] as String?,
        balanceAfter: (json['balanceAfter'] as num).toInt(),
        createdAt: json['createdAt'].toString(),
      );
}

class WalletRepository {
  WalletRepository(this._dio);

  final Dio _dio;

  Future<WalletBalance> getBalance() async {
    final response = await _dio.get<Map<String, dynamic>>('/wallet');
    return WalletBalance.fromJson(response.data!);
  }

  Future<List<WalletTransaction>> transactions() async {
    final response = await _dio.get<List<dynamic>>('/wallet/transactions');
    return (response.data ?? const [])
        .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(dioProvider));
});
