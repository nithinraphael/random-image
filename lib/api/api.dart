import 'package:aurora/models/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

final Dio _dio = Dio(
  // TODO: This should be from an env
  BaseOptions(baseUrl: 'https://november7-730026606190.europe-west1.run.app'),
);

Future<bool> _validateUrl(String url) async {
  try {
    // Use HEAD request for efficiency to check if the resource exists
    final response = await _dio.head(url);

    // Check 1: Status Code (must be 200)
    if (response.statusCode != 200) {
      return false;
    }

    return true;
  } catch (e) {
    // Any network/DNS/timeout error
    return false;
  }
}

class Api {
  static FEB<String> getRandomImage() async {
    try {
      final r = await _dio.get('/image');
      final u = r.data['url'];
      if (u is! String) {
        return left(BError('No url'));
      }
      if (!await _validateUrl(u)) {
        return left(BError('Invalid url'));
      }

      return right(u);
    } on DioException catch (e) {
      return left(BError(e.message ?? 'Dio error'));
    } catch (e) {
      return left(BError(e.toString()));
    }
  }
}

const mock1 =
    'https://plus.unsplash.com/premium_photo-1763378519176-eaa8c8e41233?q=80&w=1315&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
const mock2 =
    'https://images.unsplash.com/photo-1763286056614-0fc228bf7139?q=80&w=1336&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
const mock3 =
    'https://images.unsplash.com/photo-1763277339854-0bf3ebfbaf39?q=80&w=1291&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

final _mockImages = [mock1, mock2, mock3];

class MockApi {
  static FEB<String> getRandomImage() async => Future.delayed(
    const Duration(milliseconds: 100),
    () => right(
      _mockImages[(DateTime.now().millisecondsSinceEpoch ~/ 100) %
          _mockImages.length],
    ),
  );
}
