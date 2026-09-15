class AuthenticationRepository {
  static String signUp = "/users/signUp";
  static String users = "/users";
  static String signInWithPassword = "/auth/signIn";
  static String getOtpMail = "/auth/Otp";
  static String resendOtpMail = "/auth/ResendOtp";
  static String verifyOtpMail = "/auth/verifyOtp";
  static String forgotPassword = "/auth/ForgotPassword";
  static String resetPassword = "/auth/ResetPassword";
  static String refreshTokenPost = "/auth/refresh";
  static String signOut = "/auth/logout";

  /// Verify Offer Auth
  static String verifyOtpForOffer = "/auth/verifyOtpForOffer";
  static String userById({required int userId}) {
    return "$users/$userId";
  }

}
