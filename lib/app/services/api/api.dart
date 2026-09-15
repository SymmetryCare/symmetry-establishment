import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';

class Api {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static Api? _instance;
  factory Api(BuildContext buildContext) {
    _instance ??= Api._internal(buildContext);
    _instance!._buildContext = buildContext;
    return _instance!;
  }
  Api._internal(this._buildContext) { _initDio(); }

  BuildContext _buildContext;

  // ── Dio ───────────────────────────────────────────────────────────────────
  late final Dio _dio;
  final Dio _bareDio = Dio(BaseOptions(baseUrl: AppConfig.endpoint));

  static Dio get dio => _instance!._dio;

  // ── Refresh state ─────────────────────────────────────────────────────────
  bool _isRefreshing        = false;
  bool _isNavigatingToLogin = false;

  final List<Completer<String>> _waitingQueue = [];

  static const List<String> _authExcludedPaths = [
    '/auth/verifyOtp',
    '/auth/Otp',
    '/auth/signIn',
    '/auth/ForgotPassword',
    '/auth/ResetPassword',
    '/auth/verifyOtpForOffer',
    '/auth/refresh',
  ];

  // ── Init ──────────────────────────────────────────────────────────────────
  void _initDio() {
    _dio = Dio(BaseOptions(baseUrl: AppConfig.endpoint))
      ..interceptors.add(InterceptorsWrapper(

        onRequest: (options, handler) async {
          final token = await TokenManager.getAccessToken();
          options.headers = {
            'accept':        'application/json',
            'Content-Type':  'application/json',
            'Authorization': 'Bearer $token',
          };
          print('REQUEST => ${options.method} ${options.uri}');
          handler.next(options);
        },

        onError: (error, handler) async {
          final response = error.response;
          if (response == null) return handler.next(error);

          final path = error.requestOptions.path;
          if (_authExcludedPaths.any((p) => path.contains(p))) {
            print('🚫 Auth endpoint error — skipping refresh, passing through: $path');
            return handler.next(error);
          }

          String? message;
          if (response.data is Map) {
            message = response.data['message']?.toString();
          }

          final isUnauthorized =
              response.statusCode == 401 || message == 'Unauthorized';

          if (!isUnauthorized) {
            if (response.statusCode == 404 &&
                message == 'User with ID 0 not found') {
              return _forceLogout(handler, error);
            }
            return handler.next(error);
          }

          if (_isRefreshing) {
            print('⏳ Queued (refresh in progress): ${error.requestOptions.path}');
            final completer = Completer<String>();
            _waitingQueue.add(completer);
            try {
              final newToken = await completer.future;
              return handler.resolve(await _retry(error.requestOptions, newToken));
            } catch (_) {
              return handler.next(error);
            }
          }

          _isRefreshing = true;
          print('🔄 Starting refresh for: ${error.requestOptions.path}');

          final newToken = await _doRefresh();

          if (newToken != null && newToken.isNotEmpty) {
            print('✅ Resolving ${_waitingQueue.length} queued requests');
            for (final c in _waitingQueue) {
              c.complete(newToken);
            }
            _waitingQueue.clear();
            _isRefreshing = false;

            try {
              print('✅ Token refreshed → retrying: ${error.requestOptions.path}');
              return handler.resolve(await _retry(error.requestOptions, newToken));
            } catch (e) {
              print('Retry failed: $e');
              return handler.next(error);
            }

          } else {
            print('❌ Refresh failed → rejecting ${_waitingQueue.length} queued requests');
            for (final c in _waitingQueue) {
              c.completeError('Token refresh failed');
            }
            _waitingQueue.clear();
            _isRefreshing = false;
            return _forceLogout(handler, error);
          }
        },
      ));
  }

  // ── Retry a request with a specific token ─────────────────────────────────
  Future<Response> _retry(RequestOptions req, String token) {
    return _dio.request(
      req.path,
      data:            req.data,
      queryParameters: req.queryParameters,
      options: Options(
        method: req.method,
        headers: {
          'accept':        'application/json',
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  // ── Refresh — fires once, result broadcast to all waiters ─────────────────
  Future<String?> _doRefresh() async {
    try {
      final refreshToken = await TokenManager.getRefreshToken();

      if (refreshToken == null || refreshToken.trim().isEmpty) {
        print('❌ No refresh token in storage');
        await TokenManager.removeAccessToken();
        return null;
      }

      print('🔄 Calling /auth/refresh with token: ${refreshToken.substring(0, 20)}...');

      final res = await _bareDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'accept':       'application/json',
            'Content-Type': 'application/json',
          },
          validateStatus: (s) => true,
        ),
      );

      print('Refresh status: ${res.statusCode}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;

        if (data == null || data is! Map || data['accessToken'] == null) {
          print('❌ Malformed refresh response: $data');
          return null;
        }

        final newAccess  = data['accessToken']   ?? '';
        final newRefresh = data['refreshToken']  ?? '';
        final user       = data['user'];

        if (newAccess.isEmpty) {
          print('❌ Empty access token in refresh response');
          return null;
        }

        await TokenManager.setAccessToken(
          token:        newAccess,
          refreshToken: newRefresh,
          username:     '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim(),
          departmentId: user['departmentId']  ?? 0,
          companyId:    user['company_id']   ?? 0,
          userID:       user['userId']       ?? 0,
          email:        user['email']         ?? '',
          role:         user['role']          ?? '',
        );

        print('✅ New tokens stored successfully');
        return newAccess;

      } else {
        print('❌ Refresh rejected (${res.statusCode}): ${res.data}');
        await TokenManager.removeAccessToken();
        return null;
      }
    } catch (e) {
      print('❌ _doRefresh exception: $e');
      await TokenManager.removeAccessToken();
      return null;
    }
  }

  // ── Force logout exactly once ─────────────────────────────────────────────
  void _forceLogout(ErrorInterceptorHandler handler, DioException error) {
    TokenManager.removeAccessToken();
    if (!_isNavigatingToLogin) {
      _isNavigatingToLogin = true;
      Navigator.pushNamedAndRemoveUntil(
        _buildContext,
        LoginScreen.routeName,
            (route) => false,
      );
    }
    handler.next(error);
  }

  // ── API methods ───────────────────────────────────────────────────────────
  Future<Response> get({required String path})                           => _dio.get(path);
  Future<Response> post({required String path, required Map data})       => _dio.post(path, data: data);
  Future<Response> postList({required String path, required List data})  => _dio.post(path, data: data);
  Future<Response> patch({required String path, required Map data})      => _dio.patch(path, data: data);
  Future<Response> patchNoRequest({required String path, Map? data})     => _dio.patch(path, data: data);
  Future<Response> patchList({required String path, required List data}) => _dio.patch(path, data: data);
  Future<Response> delete({required String path})                        => _dio.delete(path);
  Future<Response> getWithQueryParam({
    required String path,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) =>
      dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

  // ✅ NEW: for binary/file downloads (PDFs, images) — skips JSON decoding
  Future<Response> getBytes({required String path}) => _dio.get(
    path,
    options: Options(responseType: ResponseType.bytes),
  );

  Future<Response> postWithFormData(
      {required String path, required FormData formData}) async {
    var response = await dio.post(
      path,
      data: formData,
    );
    return response;
  }
  Future<Response> deleteWithData({required String path, Map? data}) async {
    String token = await TokenManager.getAccessToken();
    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await dio.delete(
      '${AppConfig.endpoint}$path',
      data: data,
      options: Options(
        headers: headers,
      ),
    );
    return response;
  }
  // ── Call on logout so next login gets a fresh instance ───────────────────
  static void resetInstance() {
    _instance?._waitingQueue.clear();
    _instance = null;
  }
}