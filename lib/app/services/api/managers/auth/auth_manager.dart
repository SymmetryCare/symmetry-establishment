import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/app/services/api/api_offer.dart';
import 'package:symmetry_establishment/app/services/api/repository/auth/auth_repository.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';

import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/offer_letter_manager.dart';

class AuthManager {
  ///Sign in with Email.
  static Future<ApiData> signInWithEmail(
      String email, String password, BuildContext context) async {
    try {
      Response response = await Api(context).post(
          path: AuthenticationRepository.signInWithPassword,
          data: {"email": email, "password": password});

      if (response.statusCode == 201 || response.statusCode == 200) {
        String? access = response.data['accessToken'];
        String userName =
            "${response.data['user']['firstName']} ${response.data['user']['lastName']}";
        int companyID = response.data['user']['company_id'] ?? 0;
        int userId = response.data['user']['userId'] ?? 0;
        String userEmail = response.data['user']['email'] ?? '';
        int departmentId = response.data['user']['departmentId'] ?? 0;
        String refreshToken = response.data['refreshToken'] ?? "";
        String role = response.data['user']['role'] ?? "";

        await TokenManager.setAccessToken(
            token: access ?? "",
            refreshToken: refreshToken,
            username: userName,
            companyId: companyID,
            userID: userId,
            email: userEmail,
            departmentId: departmentId,
            role: role);

        // ✅ Fetch and store employeeId after login
        var employeeIdRaw = response.data['user']['employeeId'];
        if (employeeIdRaw != null) {
          int employeeId = employeeIdRaw;
          await TokenManager.setEmployeeId(employeeId: employeeId);
          print("✅ Employee ID stored: $employeeId");
        } else {
          print("ℹ️ No employeeId in response — skipping storage");
        }

        return ApiData(
            success: true,
            message: _extractMessage(response.data) ?? "Login successful",
            statusCode: response.statusCode!,
            data: userName,
            fieldErrors: _extractFieldErrors(response.data));
      } else {
        return ApiData(
            success: false,
            message: _extractMessage(response.data) ??
                response.statusMessage ??
                AppString.somethingWentWrong,
            statusCode: response.statusCode!,
            fieldErrors: _extractFieldErrors(response.data));
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 500;
      String message;

      switch (statusCode) {
        case 401:
          message =
              _extractPasswordMessage(e.response?.data) ?? "Invalid password.";
          break;
        case 404:
          message = _extractPasswordMessage(e.response?.data) ??
              "Account not found. Please check your email.";
          break;
        case 403:
          message = _extractPasswordMessage(e.response?.data) ??
              "Access denied. Please contact support.";
          break;
        default:
          message = _extractPasswordMessage(e.response?.data) ??
              AppString.somethingWentWrong;
      }

      return ApiData(
        success: false,
        message: message,
        statusCode: statusCode,
        fieldErrors: _extractFieldErrors(e.response?.data),
      );
    } catch (e) {
      print('error $e');
      // True exception (no network, timeout, bad JSON) — no HTTP status exists
      return ApiData(
        success: false,
        message: AppString.somethingWentWrong,
        statusCode: 500,
      );
    }
  }

  /// Extracts a human-readable message string from the response body.
  /// Handles the case where "message" is a String, OR a List of
  /// { key, message } error objects (validation errors).
  static String? _extractPasswordMessage(dynamic data) {
    if (data == null || data is! Map) return null;

    final msg = data['message'];

    if (msg is String) {
      return msg;
    }

    if (msg is List && msg.isNotEmpty) {
      // Take the first error's message, e.g. "password must be..."
      final first = msg.first;
      if (first is Map && first['message'] != null) {
        return first['message'].toString();
      }
      return first.toString();
    }

    return data['error']?.toString();
  }

  /// Extracts field-level errors. Now also checks "message" when it's
  /// a List of { key, message } objects — not just "errors".
  static List<ErrorDetail>? _extractFieldErrors(dynamic data) {
    if (data == null || data is! Map) return null;

    final raw = data['errors'] ?? data['fieldErrors'] ?? data['message'];
    if (raw == null) return null;

    final List<ErrorDetail> result = [];

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final key =
              (item['key'] ?? item['field'] ?? item['name'] ?? "").toString();
          final message =
              (item['message'] ?? item['msg'] ?? item['error'] ?? "")
                  .toString();
          if (key.isNotEmpty || message.isNotEmpty) {
            result.add(ErrorDetail(key, message));
          }
        } else if (item is String) {
          result.add(ErrorDetail("", item));
        }
      }
    } else if (raw is Map) {
      raw.forEach((key, value) {
        if (value is List) {
          for (final msg in value) {
            result.add(ErrorDetail(key.toString(), msg.toString()));
          }
        } else if (value != null) {
          result.add(ErrorDetail(key.toString(), value.toString()));
        }
      });
    }

    return result.isEmpty ? null : result;
  }

  ///Confirm Password for Forget Password Flow
  Future<ApiData> confirmPassword(
      String email, String otp, String password, BuildContext context) async {
    try {
      var response = await Api(context).post(
          path: AuthenticationRepository.resetPassword,
          data: {"email": email, "otp": int.parse(otp), "password": password});

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiData(
            statusCode: response.statusCode!,
            success: true,
            message: response.statusMessage ?? "");
      } else {
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.data["message"] ?? "");
      }
    } catch (e) {
      return ApiData(
          statusCode: 404,
          success: false,
          message: AppString.somethingWentWrong);
    }
  }

  ///Forget Password
  Future<ApiData> forgotPassword(String email, BuildContext context) async {
    try {
      var response = await Api(context).post(
          path: AuthenticationRepository.forgotPassword,
          data: {"email": email});

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiData(
            statusCode: response.statusCode!,
            success: true,
            message: response.statusMessage ?? "");
      } else {
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.data["message"] ?? "");
      }
    } catch (e) {
      return ApiData(
          statusCode: 404,
          success: false,
          message: AppString.somethingWentWrong);
    }
  }

  static Future<ApiData> getOTP(String email, BuildContext context) async {
    try {
      var response = await Api(context).post(
          path: AuthenticationRepository.getOtpMail, data: {"email": email});

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('OTP request accepted by the authentication service');
        return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: _extractMessage(response.data) ?? "OTP sent successfully",
        );
      } else {
        return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: _extractMessage(response.data) ??
              response.statusMessage ??
              AppString.somethingWentWrong,
        );
      }
    } on DioException catch (e) {
      // Dio throws for non-2xx by default, so 404 lands HERE, not in the else above
      final statusCode = e.response?.statusCode ?? 500;
      String message;

      if (statusCode == 404) {
        message = _extractMessage(e.response?.data) ??
            "Email not found. Please check and try again.";
      } else {
        message =
            _extractMessage(e.response?.data) ?? AppString.somethingWentWrong;
      }

      return ApiData(
        statusCode: statusCode,
        success: false,
        message: message,
      );
    } catch (e) {
      // Network failure, timeout, parsing error etc. — no HTTP status exists
      return ApiData(
        statusCode: 500,
        success: false,
        message: AppString.somethingWentWrong,
      );
    }
  }

  /// Pulls the message out of the API's JSON error body, whatever key it uses
  static String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) {
      return (data['message'] ?? data['error'] ?? data['detail'])?.toString();
    }
    return null;
  }

  ///Sign In otp Verification
  ///Sign In otp Verification
  static Future<ApiData> verifyOTPAndLogin(
      {required String email,
      required String otp,
      required BuildContext context}) async {
    try {
      var response = await Api(context).post(
          path: AuthenticationRepository.verifyOtpMail,
          data: {"email": email, "otp": int.parse(otp)});
      print(response);
      if (response.statusCode == 201 || response.statusCode == 200) {
        String accessToken = response.data["accessToken"] ?? "";
        String userName =
            "${response.data['user']['firstName']} ${response.data['user']['lastName']}";
        int companyID = response.data['user']['company_id'] ?? 0;
        int userId = response.data['user']['userId'] ?? 0;
        String email = response.data['user']['email'] ?? '';
        int departmentId = response.data['user']['departmentId'] ?? 0;
        String refreshToken = response.data['refreshToken'] ?? "";
        String role = response.data['user']['role'] ?? "";
        await TokenManager.setAccessToken(
            token: accessToken,
            refreshToken: refreshToken,
            username: userName,
            companyId: companyID,
            userID: userId,
            email: email,
            departmentId: departmentId,
            role: role);

        // ✅ Store employeeId directly from verifyOtp response — accept 0/null as-is, no fallback call
        var employeeIdRaw = response.data['user']['employeeId'];
        if (employeeIdRaw != null) {
          int employeeId = employeeIdRaw;
          await TokenManager.setEmployeeId(employeeId: employeeId);
          print("✅ Employee ID stored: $employeeId");
        } else {
          print(
              "ℹ️ No employeeId in response (likely Patient login) — skipping storage");
        }

        // Navigator.pushNamed(context, HomeScreen.routeName);

        return ApiData(
            statusCode: response.statusCode!,
            success: true,
            data: response.data,
            message: response.statusMessage ?? "");
      } else {
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.statusMessage ?? "");
      }
    } catch (e) {
      return ApiData(statusCode: 404, success: false, message: "Invalid OTP");
    }
  }

  ///Sign Up
  Future signUp(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      var response =
          await Api(context).post(path: AuthenticationRepository.signUp, data: {
        "email": email,
        "password": password,
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiData(
            statusCode: response.statusCode!,
            success: true,
            message: response.statusMessage ?? "");
      } else {
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.statusMessage ?? "");
      }
    } catch (e) {
      return ApiData(
          statusCode: 404,
          success: false,
          message: AppString.somethingWentWrong);
    }
  }

  /// Authentication on reguster screen HR

  Future<ApiData> verifyRefreshTokenLogin(
      {required String refreshToken, required BuildContext context}) async {
    try {
      var response = await Api(context).post(
          path: AuthenticationRepository.refreshTokenPost,
          data: {"refreshToken": refreshToken});
      print(response);
      if (response.statusCode == 201 || response.statusCode == 200) {
        String accessToken = response.data["accessToken"] ?? "";
        String userName =
            "${response.data['user']['firstName']} ${response.data['user']['lastName']}";
        int companyID = response.data['user']['company_id'] ?? 0;
        int userId = response.data['user']['userId'] ?? 0;
        String email = response.data['user']['email'] ?? '';
        int departmentId = response.data['user']['departmentId'] ?? 0;
        String refreshToken = response.data['refreshToken'] ?? "";
        String role = response.data['user']['role'] ?? "";
        TokenManager.setAccessToken(
            token: accessToken,
            refreshToken: refreshToken,
            username: userName,
            companyId: companyID,
            userID: userId,
            email: email,
            departmentId: departmentId,
            role: role);
        // Navigator.pushNamed(context, HomeScreen.routeName);

        return ApiData(
            statusCode: response.statusCode!,
            success: true,
            data: response.data,
            message: response.data['message'] ?? "");
      } else {
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.data['message'] ?? "");
      }
    } catch (e) {
      return ApiData(statusCode: 404, success: false, message: "Invalid Data");
    }
  }

  Future<ApiData> logOutuserByToken(
      {required String refreshToken, required BuildContext context}) async {
    try {
      var response = await Api(context).post(
          path: AuthenticationRepository.signOut,
          data: {"refreshToken": refreshToken});
      print(response);
      if (response.statusCode == 201 || response.statusCode == 200) {
        TokenManager.removeAccessToken();
        Navigator.pushNamedAndRemoveUntil(
            context, LoginScreen.routeName, (route) => false);
        // Navigator.pushNamed(context, HomeScreen.routeName);

        return ApiData(
            statusCode: response.statusCode!,
            success: true,
            data: response.data,
            message: response.data['message'] ?? "");
      } else {
        return ApiData(
            statusCode: response.statusCode!,
            success: false,
            message: response.data['message'] ?? "");
      }
    } catch (e) {
      return ApiData(statusCode: 404, success: false, message: "Invalid OTP");
    }
  }
}

Future<ApiDataRegister> verifyOTPAndRegister(
    {required String email,
    required String otp,
    required BuildContext context}) async {
  /// Backends return the error message under different keys and shapes —
  /// this checks the common ones.
  String? _extractBackendMessage(dynamic data) {
    if (data == null) return null;
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) {
      final msg =
          data['message'] ?? data['error'] ?? data['msg'] ?? data['detail'];
      if (msg is String && msg.isNotEmpty) return msg;
      // some backends send {"message": ["error1", "error2"]}
      if (msg is List && msg.isNotEmpty) return msg.join(', ');
    }
    return null;
  }

  try {
    var response = await ApiOffer(context).post(
        path: AuthenticationRepository.verifyOtpForOffer,
        data: {"email": email, "otp": int.parse(otp)});
    print(response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // ── Always extract and store, regardless of status ──
      String accessToken = response.data["accessToken"] ?? "";
      String userName =
          "${response.data['user']['firstName']} ${response.data['user']['lastName']}";
      int companyID = response.data['user']['company_id'];
      String emailId = response.data['user']['email'];
      int userId = response.data['user']['userId'];
      int departmentId = response.data['user']['departmentId'] ?? 0;
      int templateId = response.data['user']['template_id'] ?? 0;
      int enrollId = response.data['user']['employeeEnrollId'] ?? 0;
      String role = response.data['user']['status'] ?? '';

      TokenManager.setAccessRegisterToken(
          token: accessToken,
          username: userName,
          companyId: companyID,
          emailId: emailId,
          userID: userId,
          depID: departmentId,
          templateId: templateId,
          enrollId: enrollId,
          userRole: role);

      // Navigator.pushNamed(context, HomeScreen.routeName);
      // print("dep id ;;;;${departmentId}");
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: true,
          message: response.data['message'] ?? "",
          userRole: role);
    } else {
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: false,
          message: _extractBackendMessage(response.data) ??
              "Something went wrong. Please try again.");
    }
  } on DioException catch (e) {
    // ── backend responded with an error status (400/401/404/500 etc.)
    final String? backendMessage = _extractBackendMessage(e.response?.data);
    return ApiDataRegister(
      statusCode: e.response?.statusCode ?? 500,
      success: false,
      message: backendMessage ?? "Something went wrong. Please try again.",
    );
  } on FormatException {
    // ── int.parse(otp) failed — user typed something non-numeric
    return ApiDataRegister(
        statusCode: 400, success: false, message: "Please enter a valid OTP.");
  } catch (e) {
    // ── anything else (no internet, timeout, unexpected)
    return ApiDataRegister(
        statusCode: 500,
        success: false,
        message:
            "Unable to verify OTP. Please check your connection and try again.");
  }
}
