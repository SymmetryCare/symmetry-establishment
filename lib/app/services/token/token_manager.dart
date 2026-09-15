import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static Future<String> getAccessToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString("accessToken");
    bool? isOnBoardToken = await getIsOnBoardingToken();
    if (isOnBoardToken) {
      token = sharedPreferences.getString("accessTokenRegister");
    } else {}
    return token ?? "";
  }

  static Future<String> getRefreshToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString("refreshToken");
    return token ?? "";
  }

  static Future<String> getUserName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userName = sharedPreferences.getString("userName");
    return userName ?? "";
  }

  static Future<String> getEmail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? email = sharedPreferences.getString("email");
    return email ?? "";
  }

  static Future<int> getdepartmentId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? departmentId = sharedPreferences.getInt("departmentId");
    return departmentId ?? 0;
  }

  static Future<int> getCompanyId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? companyId = sharedPreferences.getInt("companyId");
    return companyId ?? 0;
  }

  static Future<int> getuserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    return userId ?? 0;
  }

  static Future<bool> getIsOnBoardingToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? isOnBoarding = sharedPreferences.getBool("isOnBoarding");
    return isOnBoarding ?? false;
  }

  /// ✅ Set & Get Employee ID
  static Future<void> setEmployeeId({required int employeeId}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print('employeeId set $employeeId');
    sharedPreferences.setInt("employeeId", employeeId);
  }

  static Future<int> getEmployeeId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? employeeId = sharedPreferences.getInt("employeeId");
    return employeeId ?? 0;
  }

  static Future<String> getRole() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? role = sharedPreferences.getString("role");
    return role ?? '';
  }

  static Future<void> setAccessToken(
      {required String token,
      required String refreshToken,
      required String username,
      required int departmentId,
      required int companyId,
      required int userID,
      required String email,
      required String role}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print('User Name set $username');
    print('Authentication tokens stored securely');
    print('companyId ${companyId}');
    print('userID ${userID}');
    print('email ${email}');
    print('departmentId ${departmentId}');
    sharedPreferences.setString("accessToken", token);
    sharedPreferences.setString("refreshToken", refreshToken);
    sharedPreferences.setString("userName", username);
    sharedPreferences.setInt("companyId", companyId);
    sharedPreferences.setInt("userId", userID);
    sharedPreferences.setString("email", email);
    sharedPreferences.setInt("departmentId", departmentId);
    sharedPreferences.setBool("isOnBoarding", false);
    sharedPreferences.setString("role", role);
  }

  static void setFcmToken({required String fcmToken}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print('FCM token stored securely');
    sharedPreferences.setString("fcmTokenRegistered", fcmToken);
  }

  static void setAccessRegisterToken(
      {required String token,
      required String username,
      required int companyId,
      required String emailId,
      required int userID,
      required int depID,
      required int templateId,
      required int enrollId,
      required String userRole}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print('userNameRegister set $username');
    print('Registration token stored securely');
    print('companyIdRegister ${companyId}');
    print('User Id ${userID}');
    print("employee Id ${emailId}");
    sharedPreferences.setString("accessTokenRegister", token);
    sharedPreferences.setString("userNameRegister", username);
    sharedPreferences.setInt("companyIdRegister", companyId);
    sharedPreferences.setString("emailIdRegistered", emailId);
    sharedPreferences.setInt("userID", userID);
    sharedPreferences.setInt("departmentId", depID);
    sharedPreferences.setInt("template_id", templateId);
    sharedPreferences.setInt("employeeEnrollId", enrollId);
    sharedPreferences.setBool("isOnBoarding", true);
    sharedPreferences.setString("status", userRole);
  }

  static Future<String> getFcmTokenRegister() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? fcmToken = sharedPreferences.getString("fcmTokenRegistered");
    return fcmToken ?? "";
  }

  static Future<int> getdepIdRegister() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? depIdRegistered = sharedPreferences.getInt("departmentId");
    return depIdRegistered ?? 0;
  }

  static Future<int> getTemplateIdRegister() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? depIdRegistered = sharedPreferences.getInt("template_id");
    return depIdRegistered ?? 0;
  }

  static Future<int> getEnrollIdRegister() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? depIdRegistered = sharedPreferences.getInt("employeeEnrollId");
    return depIdRegistered ?? 0;
  }

  static Future<int> getCompanyIdRegister() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? companyIdRegistered = sharedPreferences.getInt("companyIdRegister");
    return companyIdRegistered ?? 0;
  }

  static Future<String> getEmailIdRegister() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? emilIdRegistred = sharedPreferences.getString("emailIdRegistered");
    return emilIdRegistred ?? "";
  }

  static Future<String> getUserRoleRegister() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? emilIdRegistred = sharedPreferences.getString("status");
    return emilIdRegistred ?? "";
  }

  static Future<void> removeAccessToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("refreshToken", "");
    await sharedPreferences.setString("accessToken", "");
  }

  static void removeFCMToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("fcmTokenRegistered", "");
  }

  static void removeAccessRegisterToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("accessTokenRegister", "");
  }

  static Future<int> getUserID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? userIdRegistred = sharedPreferences.getInt("userID");
    return userIdRegistred ?? 0;
  }

  /// ✅ NEW — Clears every user-scoped key set during login/registration.
  /// Call this on logout so no stale employeeId/userId/companyId etc.
  /// leaks into the next user's session.
  static Future<void> clearSession() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print('Clearing full session from SharedPreferences');
    await sharedPreferences.remove("accessToken");
    await sharedPreferences.remove("refreshToken");
    await sharedPreferences.remove("userName");
    await sharedPreferences.remove("email");
    await sharedPreferences.remove("departmentId");
    await sharedPreferences.remove("companyId");
    await sharedPreferences.remove("userId");
    await sharedPreferences.remove("employeeId");
    await sharedPreferences.remove("role");
    await sharedPreferences.remove("isOnBoarding");
    await sharedPreferences.remove("fcmTokenRegistered");
    // Registration/onboarding-specific keys
    await sharedPreferences.remove("accessTokenRegister");
    await sharedPreferences.remove("userNameRegister");
    await sharedPreferences.remove("companyIdRegister");
    await sharedPreferences.remove("emailIdRegistered");
    await sharedPreferences.remove("userID");
    await sharedPreferences.remove("template_id");
    await sharedPreferences.remove("employeeEnrollId");
    await sharedPreferences.remove("status");
  }
}
