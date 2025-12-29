import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Manages anonymous user token and future OAuth integration
class AuthManager {
  static const String _anonymousUserIdKey = 'anonymous_user_id';

  final SharedPreferences _prefs;
  String? _currentUserId;

  AuthManager(this._prefs);

  /// Get or create anonymous user ID
  Future<String> getCurrentUserId() async {
    if (_currentUserId != null) return _currentUserId!;

    // Check if we already have an anonymous ID
    _currentUserId = _prefs.getString(_anonymousUserIdKey);

    if (_currentUserId == null) {
      // Create new anonymous user
      _currentUserId = 'anon_${const Uuid().v4()}';
      await _prefs.setString(_anonymousUserIdKey, _currentUserId!);
    }

    return _currentUserId!;
  }

  /// Future: Switch to authenticated user (OAuth)
  Future<void> signInWithGoogle() async {
    // TODO: Implement Google Sign-In
    // 1. Sign in with google_sign_in package
    // 2. Get user ID from Google
    // 3. Migrate anonymous data to new user ID
    // 4. Update _currentUserId
    // 5. Save to SharedPreferences
    throw UnimplementedError('OAuth not implemented yet');
  }

  /// Sign out (back to anonymous)
  Future<void> signOut() async {
    // Create new anonymous ID
    _currentUserId = 'anon_${const Uuid().v4()}';
    await _prefs.setString(_anonymousUserIdKey, _currentUserId!);
  }

  /// Check if user is authenticated (vs anonymous)
  bool get isAuthenticated => _currentUserId?.startsWith('anon_') == false;

  /// Get display name
  String get displayName => isAuthenticated ? 'User' : 'Guest';
}
