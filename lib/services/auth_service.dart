import 'dart:io' as io;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? message;
  final String? targetUrl;
  final String? sessionId;

  AuthResult({
    required this.success,
    this.errorMessage,
    this.message,
    this.targetUrl,
    this.sessionId,
  });
}

class AuthService {
  static const String base4W = 'https://merigarage.com/GarageAdmin/';
  static const String base2W = 'https://merigarage.com/GarageAdmin2W/';

  static String getBaseUrl(bool is2Wheeler) => is2Wheeler ? base2W : base4W;

  static String getLoginUrl(bool is2Wheeler) => '${getBaseUrl(is2Wheeler)}login.php';
  static String getRegistrationUrl(bool is2Wheeler) => '${getBaseUrl(is2Wheeler)}registration.php';
  static String getForgotPasswordUrl(bool is2Wheeler) => '${getBaseUrl(is2Wheeler)}forgot-password.php';
  static String getAdminFunctionUrl(bool is2Wheeler) => '${getBaseUrl(is2Wheeler)}adminFunction.php';

  /// Performs login for either 4W or 2W, Owner (admin) or Staff (employee).
  static Future<AuthResult> login({
    required bool is2Wheeler,
    required bool isStaff,
    required String username,
    required String password,
  }) async {
    final client = io.HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;

    try {
      final functionUri = Uri.parse(getAdminFunctionUrl(is2Wheeler));
      final request = await client.postUrl(functionUri).timeout(const Duration(seconds: 15));
      request.followRedirects = false;
      request.headers.contentType = io.ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');

      final role = isStaff ? 'employee' : 'admin';
      final body = 'login_type=${Uri.encodeComponent(role)}'
          '&login_id=${Uri.encodeComponent(username.trim())}'
          '&password=${Uri.encodeComponent(password)}'
          '&btn-sub=Login';

      request.write(body);
      final response = await request.close().timeout(const Duration(seconds: 15));

      String? phpSessionId;
      for (final cookie in response.cookies) {
        if (cookie.name == 'PHPSESSID') {
          phpSessionId = cookie.value;
          break;
        }
      }

      final location = response.headers.value('location') ?? '';

      // If location contains login.php, login was rejected by the server
      if (location.isEmpty || location.contains('login.php')) {
        String? scrapedError;
        if (phpSessionId != null) {
          try {
            final loginUri = Uri.parse(getLoginUrl(is2Wheeler));
            final loginReq = await client.getUrl(loginUri).timeout(const Duration(seconds: 10));
            loginReq.cookies.add(io.Cookie('PHPSESSID', phpSessionId));
            final loginRes = await loginReq.close().timeout(const Duration(seconds: 10));
            final loginHtml = await utf8.decodeStream(loginRes);

            final alertMatch = RegExp(
              r'<div[^>]*class="[^"]*alert-error[^"]*"[^>]*>(.*?)</div>',
              dotAll: true,
            ).firstMatch(loginHtml);

            if (alertMatch != null) {
              final raw = alertMatch.group(1)?.replaceAll(RegExp(r'<[^>]*>'), '').trim();
              if (raw != null && raw.isNotEmpty) {
                scrapedError = raw;
              }
            }
          } catch (_) {}
        }

        return AuthResult(
          success: false,
          errorMessage: scrapedError ?? 'Invalid credentials. Please verify your credentials and try again.',
        );
      }

      // Login Succeeded!
      final targetLocation = location.startsWith('http')
          ? location
          : '${getBaseUrl(is2Wheeler)}$location';

      // Inject session cookie into InAppWebView so user is already logged in
      if (phpSessionId != null) {
        try {
          final cookieManager = CookieManager.instance();
          final domainUri = WebUri(getBaseUrl(is2Wheeler));
          await cookieManager.setCookie(
            url: domainUri,
            name: 'PHPSESSID',
            value: phpSessionId,
            domain: 'merigarage.com',
            path: '/',
            isSecure: true,
          );
        } catch (_) {}
      }

      return AuthResult(
        success: true,
        targetUrl: targetLocation,
        sessionId: phpSessionId,
      );
    } on TimeoutException {
      return AuthResult(
        success: false,
        errorMessage: 'Connection timed out. Please check your internet connection and try again.',
      );
    } on io.SocketException {
      return AuthResult(
        success: false,
        errorMessage: 'Unable to connect to Meri Garage server. Please check your network.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Login failed: ${e.toString()}',
      );
    } finally {
      client.close();
    }
  }

  /// Registers a new Garage (Owner) for 4W or 2W
  static Future<AuthResult> register({
    required bool is2Wheeler,
    required String garageName,
    required String mobile,
    required String email,
    required String address,
    required String password,
  }) async {
    final client = io.HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;

    try {
      final functionUri = Uri.parse(getAdminFunctionUrl(is2Wheeler));
      final request = await client.postUrl(functionUri).timeout(const Duration(seconds: 15));
      request.followRedirects = false;
      request.headers.contentType = io.ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');

      final body = 'gname=${Uri.encodeComponent(garageName.trim())}'
          '&mobile=${Uri.encodeComponent(mobile.trim())}'
          '&email=${Uri.encodeComponent(email.trim())}'
          '&address=${Uri.encodeComponent(address.trim())}'
          '&password=${Uri.encodeComponent(password)}'
          '&btn-sub2=';

      request.write(body);
      final response = await request.close().timeout(const Duration(seconds: 15));

      String? phpSessionId;
      for (final cookie in response.cookies) {
        if (cookie.name == 'PHPSESSID') {
          phpSessionId = cookie.value;
          break;
        }
      }

      // Check login page for any alert error or success message
      String? errorMessage;
      String? successMessage;

      if (phpSessionId != null) {
        try {
          final loginUri = Uri.parse(getLoginUrl(is2Wheeler));
          final loginReq = await client.getUrl(loginUri).timeout(const Duration(seconds: 10));
          loginReq.cookies.add(io.Cookie('PHPSESSID', phpSessionId));
          final loginRes = await loginReq.close().timeout(const Duration(seconds: 10));
          final loginHtml = await utf8.decodeStream(loginRes);

          final alertErrorMatch = RegExp(
            r'<div[^>]*class="[^"]*alert-error[^"]*"[^>]*>(.*?)</div>',
            dotAll: true,
          ).firstMatch(loginHtml);

          if (alertErrorMatch != null) {
            errorMessage = alertErrorMatch.group(1)?.replaceAll(RegExp(r'<[^>]*>'), '').trim();
          }

          final alertSuccessMatch = RegExp(
            r'<div[^>]*class="[^"]*alert-success[^"]*"[^>]*>(.*?)</div>',
            dotAll: true,
          ).firstMatch(loginHtml);

          if (alertSuccessMatch != null) {
            successMessage = alertSuccessMatch.group(1)?.replaceAll(RegExp(r'<[^>]*>'), '').trim();
          }
        } catch (_) {}
      }

      if (errorMessage != null && errorMessage.isNotEmpty) {
        return AuthResult(success: false, errorMessage: errorMessage);
      }

      return AuthResult(
        success: true,
        message: successMessage ?? 'Registration successful! Please sign in with your credentials.',
      );
    } on TimeoutException {
      return AuthResult(
        success: false,
        errorMessage: 'Registration timed out. Please check your connection.',
      );
    } on io.SocketException {
      return AuthResult(
        success: false,
        errorMessage: 'Network error. Please verify your internet connection.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Registration failed: ${e.toString()}',
      );
    } finally {
      client.close();
    }
  }

  /// Updates owner password via forgot-password flow
  static Future<AuthResult> updatePassword({
    required bool is2Wheeler,
    required String mobile,
    required String newPassword,
  }) async {
    final client = io.HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;

    try {
      final functionUri = Uri.parse(getAdminFunctionUrl(is2Wheeler));
      final request = await client.postUrl(functionUri).timeout(const Duration(seconds: 15));
      request.followRedirects = false;
      request.headers.contentType = io.ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');

      final body = 'g_mob=${Uri.encodeComponent(mobile.trim())}'
          '&password=${Uri.encodeComponent(newPassword)}'
          '&btn-sub3=Update+Password';

      request.write(body);
      final response = await request.close().timeout(const Duration(seconds: 15));

      String? phpSessionId;
      for (final cookie in response.cookies) {
        if (cookie.name == 'PHPSESSID') {
          phpSessionId = cookie.value;
          break;
        }
      }

      // Check redirected page for messages
      if (phpSessionId != null) {
        try {
          final loginUri = Uri.parse(getLoginUrl(is2Wheeler));
          final loginReq = await client.getUrl(loginUri).timeout(const Duration(seconds: 10));
          loginReq.cookies.add(io.Cookie('PHPSESSID', phpSessionId));
          final loginRes = await loginReq.close().timeout(const Duration(seconds: 10));
          final loginHtml = await utf8.decodeStream(loginRes);

          final alertErrorMatch = RegExp(
            r'<div[^>]*class="[^"]*alert-error[^"]*"[^>]*>(.*?)</div>',
            dotAll: true,
          ).firstMatch(loginHtml);

          if (alertErrorMatch != null) {
            final errorText = alertErrorMatch.group(1)?.replaceAll(RegExp(r'<[^>]*>'), '').trim();
            if (errorText != null && errorText.isNotEmpty) {
              return AuthResult(success: false, errorMessage: errorText);
            }
          }
        } catch (_) {}
      }

      return AuthResult(
        success: true,
        message: 'Password updated successfully! Please login with your new password.',
      );
    } on TimeoutException {
      return AuthResult(
        success: false,
        errorMessage: 'Request timed out. Please check your internet connection.',
      );
    } on io.SocketException {
      return AuthResult(
        success: false,
        errorMessage: 'Network error. Please verify your connection.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Password update failed: ${e.toString()}',
      );
    } finally {
      client.close();
    }
  }
}
