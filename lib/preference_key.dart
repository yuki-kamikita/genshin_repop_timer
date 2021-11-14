import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// SharedPreferencesを一元管理
///
/// 参考：https://blog.dalt.me/2356
enum PreferenceKey {
  originalResinCount,
  Windwail,
  Stormbearer,
  Stormterror,
  Qingce,
  Lisha,
  Guyun,
  Qingyun,
  Aocang,
  Narukami,
  Kannazuka,
  Yashiori,
  Watatsumi,
  Seirai,
  transformer,
  notionTransformer
}

extension PreferenceKeyEx on PreferenceKey {
  String get keyString {
    PreferenceKey key = this;
    return key.toString().split('.')[1];
  }

  Future<String> name() async {
    return keyString;
  }

  Future<bool> setInt(int value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setInt(keyString, value);
  }

  Future<int> getInt(int defaultValue) async {
    final pref = await SharedPreferences.getInstance();
    if (pref.containsKey(keyString)) {
      return pref.getInt(keyString)!;
    } else {
      return defaultValue;
    }
  }

  Future<bool> setString(String value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(keyString, value);
  }

  Future<String> getString(String defaultValue) async {
    final pref = await SharedPreferences.getInstance();
    if (pref.containsKey(keyString)) {
      return pref.getString(keyString)!;
    } else {
      return defaultValue;
    }
  }

  Future<bool> setBoolean(bool value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setBool(keyString, value);
  }

  Future<bool> getBoolean(bool defaultValue) async {
    final pref = await SharedPreferences.getInstance();
    if (pref.containsKey(keyString)) {
      return pref.getBool(keyString)!;
    } else {
      return defaultValue;
    }
  }

  // TODO: DateTimeとTZDateTime使ってるの無駄だから統一したい
  // TODO: 多言語対応の時にタイムゾーン付きにしたり、UTCで保存したり
  Future<bool> setDateTime(DateTime value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(keyString, value.toString());
  }

  Future<DateTime> getDateTime() async {
    return DateTime.parse(await getString('1970-01-01'));
  }

  Future<tz.TZDateTime> getTZDateTime() async {
    // DateTime dateTime = DateTime.parse(prefs.getString(key) ?? '2021-01-01');
    return tz.TZDateTime.parse(tz.UTC, await getString('1970-01-01')).add(Duration(hours: 9)); // 日本時間に変換
    // return tz.TZDateTime.from(dateTime, tz.UTC);
  }

}