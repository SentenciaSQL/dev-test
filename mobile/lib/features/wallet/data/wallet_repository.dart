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

class WalletRepository {
  WalletRepository(this._dio);

  final Dio _dio;

  Future<WalletBalance> getBalance() async {
    final response = await _dio.get<Map<String, dynamic>>('/wallet');
    return WalletBalance.fromJson(response.data!);
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(dioProvider));
});
