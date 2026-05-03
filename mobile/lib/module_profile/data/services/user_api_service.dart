import 'package:shop/module_profile/domain/models/user/user.dart';
import 'package:shop/services/dio_service/dio_api_client.dart';
import 'package:shop/utils/result.dart';

class UserApiService {
  final DioApiClient _apiClient;

  UserApiService(this._apiClient);

  Future<Result<User>> fetchCurrentUser() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      if (response.statusCode == 200) {
        return Result.ok(User.fromJson(response.data));
      }
      return Result.error(Exception('Failed to load user'));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}