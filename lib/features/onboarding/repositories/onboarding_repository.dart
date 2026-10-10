import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/family_model.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OnboardingRepository(dio: dio);
});

class OnboardingRepository {
  final Dio dio;

  OnboardingRepository({required this.dio});

  Future<FamilyModel> createFamily({
    required String name,
    required String icon,
    required String iconColor,
    required String iconBg,
  }) async {
    final response = await dio.post(
      ApiEndpoints.family,
      data: {
        'name': name.trim(),
        'icon': icon,
        'icon_color': iconColor,
        'icon_bg': iconBg,
      },
    );
    return FamilyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FamilyModel> joinFamily({required String inviteCode}) async {
    final cleanCode = inviteCode.replaceAll('-', '').trim().toUpperCase();
    final response = await dio.post(
      ApiEndpoints.familyJoin,
      data: {
        'invite_code': cleanCode,
      },
    );
    return FamilyModel.fromJson(response.data as Map<String, dynamic>);
  }
}
