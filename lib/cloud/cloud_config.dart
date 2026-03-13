import 'package:shared_preferences/shared_preferences.dart';

/// Manages cloud feature preferences.
class CloudConfig {
  static const _enabledKey = 'cloud_enabled';
  static const _hasSeenNoticeKey = 'cloud_notice_seen';

  final SharedPreferences _prefs;
  CloudConfig(this._prefs);

  bool get isEnabled => _prefs.getBool(_enabledKey) ?? false;
  Future<void> setEnabled(bool value) => _prefs.setBool(_enabledKey, value);

  bool get hasSeenPrivacyNotice => _prefs.getBool(_hasSeenNoticeKey) ?? false;
  Future<void> markPrivacyNoticeSeen() => _prefs.setBool(_hasSeenNoticeKey, true);
}
